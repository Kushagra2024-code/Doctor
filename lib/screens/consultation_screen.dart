import 'dart:io';
import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/speech_service.dart';
import '../services/gemini_service.dart';
import '../services/tts_service.dart';
import '../services/report_service.dart';
import '../services/document_service.dart';
import '../widgets/mic_button.dart';
import '../widgets/transcript_view.dart';
import 'report_screen.dart';

/// Main consultation screen with voice interaction
class ConsultationScreen extends StatefulWidget {
  final Doctor doctor;

  const ConsultationScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final SpeechService _speechService = SpeechService();
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();
  final ReportService _reportService = ReportService();
  final DocumentService _documentService = DocumentService();
  final ScrollController _scrollController = ScrollController();

  final List<TranscriptMessage> _messages = [];
  final List<String> _conversationHistory = [];

  bool _isListening = false;
  bool _isProcessing = false;
  String _currentTranscript = '';
  String? _errorMessage;
  File? _selectedDocument;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _sendWelcomeMessage();
  }

  Future<void> _initializeServices() async {
    try {
      await _speechService.initialize();
      await _ttsService.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize services: ${e.toString()}';
      });
    }
  }

  Future<void> _sendWelcomeMessage() async {
    final welcomeText =
        'Hello! I\'m ${widget.doctor.name}. How can I help you today?';

    setState(() {
      _messages.add(TranscriptMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    await _ttsService.speak(welcomeText);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isListening = true;
        _currentTranscript = '';
        _errorMessage = null;
      });

      await _speechService.startListening(
        onResult: (text) async {
          setState(() {
            _currentTranscript = text;
          });
          await _processUserInput(text);
        },
        onPartialResult: (text) {
          setState(() {
            _currentTranscript = text;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _processUserInput(String userText) async {
    if (userText.trim().isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    // Stop listening
    await _speechService.stopListening();

    // Add user message to transcript
    setState(() {
      _messages.add(TranscriptMessage(
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
        documentPath: _selectedDocument?.path,
      ));
      _currentTranscript = '';
    });

    _scrollToBottom();

    // Add to conversation history
    _conversationHistory.add('USER: $userText');

    try {
      String aiResponse;
      
      // Check if document is attached
      if (_selectedDocument != null) {
        final bytes = await _documentService.readFileAsBytes(_selectedDocument!);
        if (bytes != null) {
          // Get mime type
          String mimeType = 'image/jpeg';
          final ext = _documentService.getFileExtension(_selectedDocument!.path);
          if (ext == 'png') mimeType = 'image/png';
          else if (ext == 'pdf') mimeType = 'application/pdf';
          
          // Send message with document
          aiResponse = await _geminiService.sendMessageWithDocument(
            doctor: widget.doctor,
            userMessage: userText,
            documentBytes: bytes,
            mimeType: mimeType,
            conversationHistory: _conversationHistory,
          );
        } else {
          aiResponse = await _geminiService.sendMessage(
            doctor: widget.doctor,
            userMessage: userText,
            conversationHistory: _conversationHistory,
          );
        }
        
        // Clear selected document after sending
        setState(() {
          _selectedDocument = null;
        });
      } else {
        // Get AI response without document
        aiResponse = await _geminiService.sendMessage(
          doctor: widget.doctor,
          userMessage: userText,
          conversationHistory: _conversationHistory,
        );
      }

      // Add AI response to transcript
      setState(() {
        _messages.add(TranscriptMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();

      // Add to conversation history
      _conversationHistory.add('ASSISTANT: $aiResponse');

      // Speak the response
      await _ttsService.speak(aiResponse);
    } catch (e) {
      setState(() {
        _errorMessage = 'AI Error: ${e.toString()}';
        _messages.add(TranscriptMessage(
          text: 'I apologize, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      final file = await _documentService.pickDocument();
      if (file != null) {
        setState(() {
          _selectedDocument = file;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document selected: ${file.path.split('/').last}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await _documentService.pickImageFromGallery();
      if (file != null) {
        setState(() {
          _selectedDocument = file;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image selected: ${file.path.split('/').last}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final file = await _documentService.takePhoto();
      if (file != null) {
        setState(() {
          _selectedDocument = file;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo captured'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Pick Document/PDF'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
            if (_selectedDocument != null)
              ListTile(
                leading: const Icon(Icons.clear, color: Colors.red),
                title: const Text('Remove Attachment'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedDocument = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _endConsultation() async {
    // Stop all services
    await _speechService.stopListening();
    await _ttsService.stop();

    if (_messages.length <= 1) {
      // No conversation happened
      Navigator.pop(context);
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating medical report...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Generate full transcript
      final fullTranscript = _conversationHistory.join('\n');

      // Generate and save report
      final report = await _reportService.generateAndSaveReport(
        doctor: widget.doctor,
        fullTranscript: fullTranscript,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to report screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(report: report),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      // Still allow user to go back
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    _ttsService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.doctor.emoji),
            const SizedBox(width: 8),
            Text(widget.doctor.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _endConsultation,
            tooltip: 'End Consultation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Error banner
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: theme.colorScheme.errorContainer,
              width: double.infinity,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Transcript view
          Expanded(
            child: TranscriptView(
              messages: _messages,
              scrollController: _scrollController,
            ),
          ),

          // Current transcript (while listening)
          if (_currentTranscript.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentTranscript,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Processing indicator
          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Selected document preview
          if (_selectedDocument != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _documentService.isImage(_selectedDocument!.path)
                        ? Icons.image
                        : Icons.insert_drive_file,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDocument!.path.split('/').last,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: theme.colorScheme.onTertiaryContainer,
                    onPressed: () {
                      setState(() {
                        _selectedDocument = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Buttons row
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Attachment button
                FloatingActionButton(
                  heroTag: 'attach',
                  onPressed: _showAttachmentOptions,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  child: const Icon(Icons.attach_file),
                ),
                const SizedBox(width: 24),
                // Microphone button
                MicButton(
                  isListening: _isListening,
                  onPressed: _isProcessing ? () {} : _toggleListening,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
