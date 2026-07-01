import 'package:flutter/material.dart';
import 'package:feelview/dev/test_profile_switcher.dart';
import 'package:feelview/app/elder_mode/family_tree_home.dart';
import 'package:feelview/app/elder_mode/see_more_family.dart';
import 'package:feelview/app/elder_mode/person_feed.dart';
import 'package:feelview/app/elder_mode/photo_detail.dart';
import 'package:feelview/app/elder_mode/settings.dart';
import 'package:feelview/app/elder_mode/chat/chat_thread_list.dart';
import 'package:feelview/app/elder_mode/chat/chat_conversation.dart';
import 'package:feelview/app/poster_mode/poster_home.dart';
import 'package:feelview/app/admin_mode/admin_home.dart';
import 'package:feelview/app/poster_mode/composer.dart';
import 'package:feelview/app/poster_mode/my_posts.dart';
import 'package:feelview/app/poster_mode/chat/poster_chat_thread_list.dart';
import 'package:feelview/app/poster_mode/chat/poster_chat_conversation.dart';

/// Route name constants and Navigator 2.0 (named routes) router.
class AppRouter {
  AppRouter._();

  // Route name constants
  static const String devRoot = '/';
  static const String elderHome = '/elder/home';
  static const String elderSeeMore = '/elder/see-more';
  static const String elderPersonFeed = '/elder/person-feed';
  static const String elderPhotoDetail = '/elder/photo-detail';
  static const String elderChat = '/elder/chat';
  static const String elderChatConversation = '/elder/chat/conversation';
  static const String elderSettings = '/elder/settings';
  static const String adminHome = '/admin/home';
  static const String posterHome = '/poster/home';
  static const String posterCompose = '/poster/compose';
  static const String posterMyPosts = '/poster/my-posts';
  static const String posterChat = '/poster/chat';
  static const String posterChatConversation = '/poster/chat/conversation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case devRoot:
        return _page(settings, const TestProfileSwitcher());

      // ── Elder stack ──────────────────────────────────────────────────────
      case elderHome:
        return _page(settings, const FamilyTreeHome());

      case elderSeeMore:
        return _page(settings, const SeeMoreFamily());

      case elderPersonFeed:
        return _page(settings, const PersonFeed());

      case elderPhotoDetail:
        return _page(settings, const PhotoDetail());

      case elderChat:
        return _page(settings, const ChatThreadList());

      case elderChatConversation:
        return _page(settings, const ChatConversation());

      case elderSettings:
        return _page(settings, const ElderSettings());

      // ── Admin / Poster stack ─────────────────────────────────────────────
      case adminHome:
        return _page(settings, const AdminHome());

      case posterHome:
        return _page(settings, const PosterHome());

      case posterCompose:
        return _page(settings, const PostComposer());

      case posterMyPosts:
        return _page(settings, const MyPosts());

      case posterChat:
        return _page(settings, const PosterChatThreadList());

      case posterChatConversation:
        return _page(settings, const PosterChatConversation());

      default:
        return _page(
          settings,
          Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(RouteSettings s, Widget child) =>
      MaterialPageRoute(settings: s, builder: (_) => child);
}
