import 'package:flutter/material.dart';
import '../models/doctor.dart';

/// Doctor selection card widget
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final bool isUnlocked;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = doctor.isPremium && !isUnlocked;

    return Card(
      elevation: isLocked ? 1 : 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with photo/emoji and lock icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture or emoji
                  doctor.photoUrl != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(doctor.photoUrl!),
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              doctor.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? theme.disabledColor : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Qualification
              Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 14,
                    color: isLocked ? theme.disabledColor : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.qualification,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLocked ? theme.disabledColor : theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Experience
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 14,
                    color: isLocked ? theme.disabledColor : theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.experienceYears} years experience',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLocked ? theme.disabledColor : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                doctor.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLocked
                      ? theme.disabledColor
                      : theme.textTheme.bodySmall?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Divider
              Divider(
                height: 16,
                color: theme.colorScheme.outlineVariant,
              ),

              // Bottom row: Price and Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  if (doctor.pricePerConsultation > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: isLocked ? theme.disabledColor : theme.colorScheme.secondary,
                        ),
                        Text(
                          '\$${doctor.pricePerConsultation.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked ? theme.disabledColor : theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'FREE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Premium badge
                  if (doctor.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLocked 
                            ? theme.colorScheme.errorContainer 
                            : theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLocked ? Icons.lock : Icons.check_circle,
                            size: 12,
                            color: isLocked 
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLocked ? 'Locked' : 'Unlocked',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isLocked 
                                  ? theme.colorScheme.onErrorContainer
                                  : theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
