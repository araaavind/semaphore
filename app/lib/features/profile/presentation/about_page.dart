import 'package:flutter/material.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/constants/server_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:app/init_dependencies.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/core/utils/show_snackbar.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    await serviceLocator.isReady<PackageInfo>();

    if (mounted) {
      setState(() {
        packageInfo = serviceLocator<PackageInfo>();
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        showSnackbar(
          context,
          'Could not launch $url',
          type: SnackbarType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About text
              Center(
                child: Text(
                  'Oh, hi there! 👋',
                  style: context.theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'I\'m Aravind, an indie developer and creator of Semaphore. This app is a little hobby project designed to help you and me stay up to date without the noise of social media. Think of it as your personal content curator, bringing together the information that matter to you, straight from their sources ✨ (atleast ChatGPT thinks so).',
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Anyway, I\'ll admit that this app is nothing fancy. In fact there are some good feed reader apps similar to Semaphore that you should try. But do come back 😛.',
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Being a hobby project, Semaphore might have a few quirks here and there – but that\'s part of its charm! False. Its not. Let me know of any such quirks and I\'ll try to find time to get rid of them.',
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // Support section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.secondaryContainer
                      .withAlpha(127),
                  borderRadius:
                      BorderRadius.circular(UIConstants.inputBorderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('❤️'),
                        const SizedBox(width: 8),
                        Text(
                          'Support Semaphore',
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                context.theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Currently, I am not offering paid plans or displaying ads. The project is running on my personal fund. I wish to keep this app ad-free for as long as my funds allow. So, if you find Semaphore valuable, consider buying me a coffee to help with server costs.',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () =>
                          _launchUrl('https://buymeacoffee.com/araaavind'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(
                              UIConstants.inputBorderRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('☕'),
                            const SizedBox(width: 8),
                            Text(
                              'Buy me a coffee',
                              style:
                                  context.theme.textTheme.labelLarge?.copyWith(
                                color: context.theme.colorScheme.onSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Feedback section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color:
                      context.theme.colorScheme.primaryContainer.withAlpha(127),
                  borderRadius:
                      BorderRadius.circular(UIConstants.inputBorderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '😍 Happy with Semaphore?',
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please rate the app in playstore/app store. It helps the app grow and reach more people. More importantly, it\'s a big motivation for me to keep working on the app.',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _launchUrl(
                          'https://play.google.com/store/apps/details?id=io.smphr.app'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                              UIConstants.inputBorderRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐'),
                            const SizedBox(width: 8),
                            Text(
                              'Rate and Review',
                              style:
                                  context.theme.textTheme.labelLarge?.copyWith(
                                color: context.theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Divider(
                color: context.theme.colorScheme.outline.withAlpha(180),
              ),
              const SizedBox(height: 16),

              // Contact section
              Text(
                'Contact',
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _launchUrl('https://aravindunnikrishnan.in'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceContainerLow,
                    borderRadius:
                        BorderRadius.circular(UIConstants.inputBorderRadius),
                    border: Border.all(
                      color: context.theme.colorScheme.outline.withAlpha(120),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 18,
                        color: context.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'aravindunnikrishnan.in',
                        style: context.theme.textTheme.labelLarge?.copyWith(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Found a bug? Have a feature request? Or just want to say hi? Drop me a message.',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),
              // Email
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: context.theme.colorScheme.onSurface.withAlpha(180),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () =>
                          _launchUrl('mailto:aravindmathradan@gmail.com'),
                      child: Text(
                        'aravindmathradan@gmail.com',
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Legal links
              Divider(
                color: context.theme.colorScheme.outline.withAlpha(180),
              ),
              const SizedBox(height: 16),

              // Legal links section
              Text(
                'Legal',
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildLegalLink(
                context,
                'Privacy Policy',
                () => _launchUrl(ServerConstants.privacyPolicyUrl),
                Icons.privacy_tip_outlined,
              ),

              _buildLegalLink(
                context,
                'User Agreement',
                () => _launchUrl(ServerConstants.userAgreementUrl),
                Icons.gavel_outlined,
              ),

              _buildLegalLink(
                context,
                'Account Deletion Requests',
                () => _launchUrl(ServerConstants.accountDeletionUrl),
                Icons.delete_outline_rounded,
              ),

              const SizedBox(height: 28),

              // Version info
              _buildVersionInfo(context),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Center(
      child: packageInfo != null
          ? Text(
              'Version ${packageInfo!.version}',
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.onSurface.withAlpha(160),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLegalLink(
      BuildContext context, String title, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.inputBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: context.theme.colorScheme.onSurface.withAlpha(180),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: context.theme.textTheme.titleMedium!.copyWith(
                    color: context.theme.colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.theme.colorScheme.onSurface.withAlpha(160),
            ),
          ],
        ),
      ),
    );
  }
}
