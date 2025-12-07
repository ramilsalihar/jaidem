import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/data/models/file_model.dart';
import 'package:jaidem/features/menu/presentation/cubit/menu_cubit/menu_cubit.dart';
import 'package:jaidem/features/menu/presentation/widgets/buttons/file_tab_button.dart';
import 'package:jaidem/features/menu/presentation/widgets/cards/file_card.dart';

@RoutePage()
class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  int _selectedTabIndex = 0;
  final SearchController _searchController = SearchController();
  List<FileModel> _filteredFiles = [];

  final List<String> _tabs = [
    'Презентации из тренингов',
    'Рекомендации',
    // Add more tabs as needed
  ];

  @override
  void initState() {
    super.initState();
    context.read<MenuCubit>().fetchFiles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final state = context.read<MenuCubit>().state;
    if (state is MenuLoaded) {
      setState(() {
        _filteredFiles = _filterFiles(
          state.files.results,
          _searchController.text,
        );
      });
    }
  }

  List<FileModel> _filterFiles(List<FileModel> files, String query) {
    if (query.isEmpty) return files;

    return files.where((file) {
      final titleLower = file.title.toLowerCase();
      final subdivisionLower = file.subdivision.toLowerCase();
      final queryLower = query.toLowerCase();

      return titleLower.contains(queryLower) ||
          subdivisionLower.contains(queryLower);
    }).toList();
  }

  List<FileModel> _getFilesForSelectedTab(List<FileModel> files) {
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          'База знаний',
          style: context.textTheme.headlineLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<MenuCubit, MenuState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            children: [
              // Tabs Section
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _tabs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return FileTabButton(
                      title: _tabs[index],
                      isSelected: _selectedTabIndex == index,
                      onTap: () => setState(() => _selectedTabIndex = index),
                    );
                  },
                ),
              ),

              // Search Bar
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: AppSearchField(
              //     controller: _searchController,
              //     hintText: 'Файлдарды издөңүз',
              //   ),
              // ),
              const SizedBox(height: 16),

              // Files List Content
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(MenuState state) {
    if (state is MenuLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is MenuError && state.files == null) {
      return _buildErrorState(state.message);
    }

    if (state is MenuLoaded || (state is MenuError && state.files != null)) {
      final files = state is MenuLoaded
          ? state.files.results
          : state is MenuError
              ? state.files!.results
              : <FileModel>[];

      if (files.isEmpty) {
        return _buildEmptyState();
      }

      final displayFiles = _searchController.text.isEmpty
          ? _getFilesForSelectedTab(files)
          : _filteredFiles;

      if (displayFiles.isEmpty) {
        return _buildNoResultsState();
      }

      return RefreshIndicator(
        color: const Color(0xFF5B4298),
        onRefresh: () async {
          await context.read<MenuCubit>().fetchFiles();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayFiles.length,
          itemBuilder: (context, index) {
            return FileCard(file: displayFiles[index]);
          },
        ),
      );
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Нет доступных файлов',
            style: context.textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить поисковый запрос',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Произошла ошибка',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<MenuCubit>().fetchFiles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4298),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Повторить попытку',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
