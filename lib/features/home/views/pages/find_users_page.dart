import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/widgets/auth_button.dart';
import 'package:message_me/features/home/views/widgets/user_listtile.dart';
import 'package:message_me/features/messages/views/widgets/send_message_field.dart';

import '../../logic/find_users_cubit/find_users_cubit.dart';
import '../../logic/find_users_cubit/find_users_state.dart';
import '../widgets/search_field.dart';

class FindUsersPage extends StatelessWidget {
  const FindUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindUsersCubit, FindUsersState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return _buildUI(context, state);
      },
    );
  }

  Widget _buildUI(BuildContext context, FindUsersState state) {
    if (state is FindUsersLoaded) {
      return Stack(
        children: [
          // Positioned(child: AuthButton(label: 'Start Chat')),
          Column(
            children: [
              SearchField(
                controller: context
                    .read<FindUsersCubit>()
                    .searchFieldController,
              ),
              SizedBox(height: 12.0.h),
              Expanded(
                child: ListView.builder(
                  controller: context
                      .read<FindUsersCubit>()
                      .usersScrollController,
                  itemCount: state.users.length + (state.hasMoreUsers ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.users.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final user = state.users[index];
                    return UserListTile(
                      userModel: user,
                      isSelected: state.selectedUsers.contains(user),
                      onTap: () {
                        if (!state.selectedUsers.contains(user)) {
                          context.read<FindUsersCubit>().selectUser(user);
                        } else {
                          context.read<FindUsersCubit>().unselectUser(user);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: state.selectedUsers.isNotEmpty ? 20.h : -100.h,
            left: 20.w,
            right: 20.w,
            child: MyElevatedButton(
              label: state.selectedUsers.length == 1
                  ? 'Start Chat With ${state.selectedUsers.first.name}'
                  : 'Start Chat With ${state.selectedUsers.map((user) => user.name.split(' ').first).join(', ')}',
              onPressed: () {},
            ),
          ),
        ],
      );
    } else if (state is FindUsersError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
