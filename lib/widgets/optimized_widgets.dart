import 'package:flutter/material.dart';

/// Optimized ListView with lazy loading and memory management
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final double? itemExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int cacheExtent;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent = 250,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;
  final Set<int> _visibleIndices = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Track visible items for memory optimization
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final viewportHeight = renderBox.size.height;
      final scrollOffset = _scrollController.offset;

      // Calculate visible range
      final startIndex = (scrollOffset / (widget.itemExtent ?? 80)).floor();
      final endIndex =
          ((scrollOffset + viewportHeight) / (widget.itemExtent ?? 80)).ceil();

      _visibleIndices.clear();
      for (int i = startIndex; i <= endIndex && i < widget.items.length; i++) {
        if (i >= 0) _visibleIndices.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent.toDouble(),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return RepaintBoundary(
          child: widget.itemBuilder(context, item, index),
        );
      },
    );
  }
}

/// Optimized image widget with caching and memory management
class OptimizedImage extends StatefulWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;

  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  @override
  Widget build(BuildContext context) {
    if (widget.assetPath != null) {
      return Image.asset(
        widget.assetPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.width?.toInt(),
        cacheHeight: widget.height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? const Icon(Icons.error);
        },
      );
    }

    if (widget.imageUrl != null) {
      return Image.network(
        widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.width?.toInt(),
        cacheHeight: widget.height?.toInt(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return widget.placeholder ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? const Icon(Icons.error);
        },
      );
    }

    return widget.placeholder ?? const SizedBox();
  }
}

/// Optimized card widget with performance considerations
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableHero;
  final String? heroTag;

  const OptimizedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.enableHero = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      margin: margin ?? const EdgeInsets.all(8),
      color: color,
      elevation: elevation ?? 2,
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : null,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: card,
      );
    }

    if (enableHero && heroTag != null) {
      card = Hero(
        tag: heroTag!,
        child: card,
      );
    }

    return RepaintBoundary(child: card);
  }
}
