import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/max_width_box.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/small_spinner.dart';
import '../../../core/widgets/staggered_entrance.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../providers/search_friends_provider.dart';

class SearchFriendsScreen extends ConsumerStatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  ConsumerState<SearchFriendsScreen> createState() =>
      _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends ConsumerState<SearchFriendsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchFriendsControllerProvider.notifier).search(value);
    });
  }

  Future<void> _sendRequest(String userId) async {
    try {
      await ref
          .read(searchFriendsControllerProvider.notifier)
          .sendRequest(userId);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchFriendsControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Search Friends'),
      body: SafeArea(
        child: MaxWidthBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppTextField(
                  controller: _searchController,
                  label: 'Search by name',
                  hint: 'e.g. Jane Doe',
                  suffixIcon: const Icon(Icons.search),
                  onChanged: _onChanged,
                ),
              ),
              Expanded(
                child: resultsAsync.when(
                  loading: () => const SkeletonList(),
                  error: (error, _) => AppErrorWidget(
                    message: error.toString(),
                    onRetry: () => ref
                        .read(searchFriendsControllerProvider.notifier)
                        .retry(),
                  ),
                  data: (results) {
                    if (_searchController.text.trim().isEmpty) {
                      return const EmptyStateWidget(
                        message: 'Search for friends by name.',
                        icon: Icons.person_search_outlined,
                      );
                    }
                    if (results.isEmpty) {
                      return const EmptyStateWidget(
                        message: 'No users found.',
                        icon: Icons.search_off,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      itemCount: results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return StaggeredEntrance(
                          index: index,
                          child: _SearchResultCard(
                            result: result,
                            onSendRequest: () => _sendRequest(result.user.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result, required this.onSendRequest});

  final SearchResult result;
  final VoidCallback onSendRequest;

  @override
  Widget build(BuildContext context) {
    final user = result.user;

    return Card(
      child: AppListTile(
        leading: UserAvatar(
          name: user.name,
          avatarUrl: user.avatarUrl,
          radius: 24,
        ),
        title: Text(user.name),
        subtitle: Text('@${user.username}'),
        trailing: _ActionButton(
          state: result.buttonState,
          onPressed: onSendRequest,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.state, required this.onPressed});

  final FriendRequestButtonState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case FriendRequestButtonState.sending:
        return const SmallSpinner();
      case FriendRequestButtonState.sent:
        return const OutlinedButton(onPressed: null, child: Text('Requested'));
      case FriendRequestButtonState.none:
        return AppButton(label: 'Add', onPressed: onPressed);
    }
  }
}
