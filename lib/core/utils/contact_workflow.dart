import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/router/route_names.dart';
import '../extensions/context_extensions.dart';
import '../widgets/app_action_sheet.dart';

/// Central class to manage the contact workflows and launch options.
class ContactWorkflow {
  ContactWorkflow._();

  static Future<void> call(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    final supported = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (supported) {
      await launchUrl(uri);
    } else {
      context.showSnack('Launching phone dialer for $phone…');
    }
  }

  static Future<void> email(BuildContext context, String emailAddress) async {
    final uri = Uri.parse('mailto:$emailAddress?subject=Go%20Experts%20Inquiry');
    final supported = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (supported) {
      await launchUrl(uri);
    } else {
      context.showSnack('Opening mail app for $emailAddress…');
    }
  }

  static Future<void> whatsapp(BuildContext context, String phone, [String message = 'Hi']) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    final supported = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (supported) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      context.showSnack('Opening WhatsApp for $phone…');
    }
  }

  static void chat(BuildContext context, String peerId, [String? name]) {
    // Navigate to chat detail screen
    context.push('${Routes.chat}/$peerId');
  }

  static void bookConsultation(BuildContext context, String name) {
    context.showSnack('Booking consultation with $name…');
    context.push(Routes.calendar);
  }

  static void scheduleMeeting(BuildContext context, String name) {
    context.showSnack('Scheduling meeting with $name…');
    context.push(Routes.calendar);
  }

  static void invite(BuildContext context, String name) {
    context.push(Routes.invitations);
  }

  static void hire(BuildContext context, String name) {
    context.push('${Routes.apply}?type=Hire&name=${Uri.encodeComponent(name)}');
  }

  static void invest(BuildContext context, String name) {
    context.push('${Routes.apply}?type=Investment&name=${Uri.encodeComponent(name)}');
  }

  static void expressInterest(BuildContext context, String name) {
    context.showSnack('Expressed interest in $name successfully!');
  }

  static void requestCallback(BuildContext context, String name) {
    context.showSnack('Callback requested from $name. You will be notified shortly.');
  }

  /// Shows the standard contact options action sheet.
  static void showContactOptions(BuildContext context, {required String name, required String phone, required String emailAddress}) {
    AppActionSheet.show(
      context,
      title: 'Contact $name',
      actions: [
        AppAction(
          label: 'Call Phone',
          icon: Icons.call_outlined,
          onTap: () => call(context, phone),
        ),
        AppAction(
          label: 'Send Email',
          icon: Icons.email_outlined,
          onTap: () => email(context, emailAddress),
        ),
        AppAction(
          label: 'Chat on WhatsApp',
          icon: Icons.chat_bubble_outline_rounded,
          onTap: () => whatsapp(context, phone),
        ),
        AppAction(
          label: 'Book Consultation',
          icon: Icons.calendar_today_outlined,
          onTap: () => bookConsultation(context, name),
        ),
        AppAction(
          label: 'Request Callback',
          icon: Icons.phone_callback_outlined,
          onTap: () => requestCallback(context, name),
        ),
      ],
    );
  }
}
