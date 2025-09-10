import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/school_colors.dart';
import 'school_image.dart';
import 'responsive_helper.dart';

class SchoolFooter extends StatelessWidget {
  const SchoolFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: SchoolColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: SchoolColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main footer content
          Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.isMobile(context) ? 32 : 48,
              horizontal: ResponsiveHelper.isMobile(context) ? 16 : 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ResponsiveHelper.isMobile(context)
                  ? _buildMobileFooter(context)
                  : _buildDesktopFooter(context),
            ),
          ),
          // Bottom bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: SchoolColors.primaryDark,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildBottomBar(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // School Info Section
        Expanded(
          flex: 2,
          child: _buildSchoolInfoSection(context),
        ),
        const SizedBox(width: 48),
        // Quick Links Section
        Expanded(
          child: _buildQuickLinksSection(context),
        ),
        const SizedBox(width: 32),
        // Contact Info Section
        Expanded(
          child: _buildContactSection(context),
        ),
        const SizedBox(width: 32),
        // Social Media Section
        Expanded(
          child: _buildSocialSection(context),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSchoolInfoSection(context),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _buildQuickLinksSection(context)),
            const SizedBox(width: 24),
            Expanded(child: _buildContactSection(context)),
          ],
        ),
        const SizedBox(height: 32),
        _buildSocialSection(context),
      ],
    );
  }

  Widget _buildSchoolInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // School Logo and Name
        Row(
          children: [
            SchoolImages.schoolLogo(width: 48, height: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City View School',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: SchoolColors.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Excellence in Education',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SchoolColors.secondary3,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // School Description
        Text(
          'Empowering students with quality education, modern facilities, and a nurturing environment that fosters academic excellence and personal growth.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: SchoolColors.lightText.withOpacity(0.9),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        // School Motto
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SchoolColors.secondary1.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SchoolColors.secondary2.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.school,
                color: SchoolColors.secondary3,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '"Knowledge is Power, Education is Freedom"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SchoolColors.lightText,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Quick Links'),
        const SizedBox(height: 16),
        _buildLinkList(context, [
          _FooterLink('Home', () => context.go('/')),
          _FooterLink('About Us', () => context.go('/about')),
          _FooterLink('Academics', () => context.go('/academics')),
          _FooterLink('Admissions', () => context.go('/admissions')),
          _FooterLink('Events', () => context.go('/events')),
          _FooterLink('Gallery', () => context.go('/gallery')),
          _FooterLink('Contact', () => context.go('/contact')),
        ]),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Contact Info'),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          Icons.location_on,
          'Address',
          '123 Education Street\nCity View, State 12345',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          Icons.phone,
          'Phone',
          '+1 (555) 123-4567',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          Icons.email,
          'Email',
          'info@cityviewschool.edu',
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context,
          Icons.access_time,
          'Office Hours',
          'Mon-Fri: 8:00 AM - 5:00 PM',
        ),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Follow Us'),
        const SizedBox(height: 16),
        Text(
          'Stay connected with our school community',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: SchoolColors.lightText.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildSocialButton(
              context,
              Icons.facebook,
              'Facebook',
              () => _launchSocial('facebook'),
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              context,
              Icons.camera_alt,
              'Instagram',
              () => _launchSocial('instagram'),
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              context,
              Icons.school,
              'LinkedIn',
              () => _launchSocial('linkedin'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Newsletter Signup
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SchoolColors.secondary1.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Newsletter',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SchoolColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get updates on school events and news',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SchoolColors.lightText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: SchoolColors.lightText),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: SchoolColors.lightText.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: SchoolColors.secondary3.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: SchoolColors.secondary2.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: SchoolColors.secondary2.withOpacity(0.3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _subscribeNewsletter(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SchoolColors.secondary1,
                      foregroundColor: SchoolColors.lightText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: SchoolColors.lightText,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLinkList(BuildContext context, List<_FooterLink> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: links.map((link) => _buildLinkItem(context, link)).toList(),
    );
  }

  Widget _buildLinkItem(BuildContext context, _FooterLink link) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: link.onTap,
        hoverColor: SchoolColors.secondary1.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            link.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SchoolColors.lightText.withOpacity(0.9),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: SchoolColors.secondary2,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SchoolColors.secondary3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SchoolColors.lightText.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SchoolColors.secondary1.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: SchoolColors.secondary2.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: SchoolColors.secondary3,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: SchoolColors.lightText.withOpacity(0.8),
        );
    
    final links = [
      _buildBottomLink(context, 'Privacy Policy', _showPrivacyPolicy),
      _buildBottomLink(context, 'Terms of Service', _showTermsOfService),
      _buildBottomLink(context, 'Accessibility', _showAccessibility),
    ];
    
    final copyright = Text(
      '© ${DateTime.now().year} City View School. All rights reserved.',
      style: textStyle,
    );
    
    // For mobile, stack the copyright and links vertically
    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: copyright,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: links,
          ),
        ],
      );
    }
    
    // For desktop, show copyright on left, links on right
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen is too narrow, stack the content
        if (constraints.maxWidth < 800) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: copyright,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: links,
              ),
            ],
          );
        }
        
        // For wider screens, use row layout
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: copyright,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 16,
                children: links,
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBottomLink(
    BuildContext context, 
    String text, 
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: SchoolColors.lightText.withOpacity(0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _launchSocial(String platform) {
    // TODO: Implement social media links
    print('Launching $platform');
  }

  void _subscribeNewsletter() {
    // TODO: Implement newsletter subscription
    print('Newsletter subscription');
  }

  void _showPrivacyPolicy() {
    // TODO: Show privacy policy
    print('Show privacy policy');
  }

  void _showTermsOfService() {
    // TODO: Show terms of service
    print('Show terms of service');
  }

  void _showAccessibility() {
    // TODO: Show accessibility information
    print('Show accessibility info');
  }
}

class _FooterLink {
  final String title;
  final VoidCallback onTap;

  _FooterLink(this.title, this.onTap);
}
