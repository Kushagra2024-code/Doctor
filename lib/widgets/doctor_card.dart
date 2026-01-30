import 'package:flutter/material.dart';
import '../models/doctor.dart';

/// Doctor selection card widget
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = doctor.isPremium;

    return Card(
      elevation: isLocked ? 1 : 3,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with emoji and lock icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    doctor.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  if (isLocked)
                    Icon(
                      Icons.lock,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Doctor name
              Text(
                doctor.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? theme.disabledColor : null,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                doctor.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLocked
                      ? theme.disabledColor
                      : theme.textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Premium badge or Free badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isLocked
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLocked ? 'Premium (Locked)' : 'Free',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isLocked
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Locked message
              if (isLocked) ...[
                const SizedBox(height: 8),
                Text(
                  'Upgrade not available (Demo restriction)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
