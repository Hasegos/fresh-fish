import 'dart:convert';
import 'package:flutter/material.dart';

/// 이미지 로딩 실패 시 폴백 이미지를 표시하는 위젯
/// 
/// 피그마에서 받은 ImageWithFallback 컴포넌트를 Flutter로 변환한 버전입니다.
class ImageWithFallback extends StatefulWidget {
  /// 이미지 URL 또는 asset 경로
  final String? src;
  
  /// 대체 텍스트 (접근성)
  final String? alt;
  
  /// 이미지 너비
  final double? width;
  
  /// 이미지 높이
  final double? height;
  
  /// 이미지 맞춤 방식
  final BoxFit? fit;
  
  /// 추가 스타일 속성
  final BoxDecoration? decoration;
  
  /// 에러 발생 시 표시할 위젯 (선택사항)
  final Widget? errorWidget;
  
  /// 원본 URL 저장 (디버깅용)
  final String? originalUrl;

  const ImageWithFallback({
    Key? key,
    this.src,
    this.alt,
    this.width,
    this.height,
    this.fit,
    this.decoration,
    this.errorWidget,
    this.originalUrl,
  }) : super(key: key);

  @override
  State<ImageWithFallback> createState() => _ImageWithFallbackState();
}

class _ImageWithFallbackState extends State<ImageWithFallback> {
  bool _didError = false;
  String? _errorImageSrc;

  @override
  void initState() {
    super.initState();
    // Base64 인코딩된 SVG 에러 이미지
    _errorImageSrc =
        'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODgiIGhlaWdodD0iODgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBvcGFjaXR5PSIuMyIgZmlsbD0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIzLjciPjxyZWN0IHg9IjE2IiB5PSIxNiIgd2lkdGg9IjU2IiBoZWlnaHQ9IjU2IiByeD0iNiIvPjxwYXRoIGQ9Im0xNiA1OCAxNi0xOCAzMiAzMiIvPjxjaXJjbGUgY3g9IjUzIiBjeT0iMzUiIHI9IjciLz48L3N2Zz4KCg==';
  }

  void _handleError() {
    if (!_didError) {
      setState(() {
        _didError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_didError || widget.src == null || widget.src!.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: widget.decoration ??
            BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
        child: widget.errorWidget ??
            Center(
              child: _buildErrorImage(),
            ),
      );
    }

    // 네트워크 이미지인지 asset 이미지인지 판단
    final isNetworkImage = widget.src!.startsWith('http://') ||
        widget.src!.startsWith('https://') ||
        widget.src!.startsWith('data:');

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.decoration,
      child: isNetworkImage
          ? Image.network(
              widget.src!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit ?? BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                _handleError();
                return Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: widget.decoration ??
                      BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                  child: widget.errorWidget ?? _buildErrorImage(),
                );
              },
            )
          : Image.asset(
              widget.src!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit ?? BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                _handleError();
                return Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: widget.decoration ??
                      BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                  child: widget.errorWidget ?? _buildErrorImage(),
                );
              },
            ),
    );
  }

  Widget _buildErrorImage() {
    // Base64 이미지를 표시하기 위해 MemoryImage 사용
    // 또는 더 나은 방법으로는 SVG를 직접 렌더링하거나
    // asset으로 관리하는 것을 권장합니다.
    try {
      if (_errorImageSrc != null && _errorImageSrc!.contains(',')) {
        final base64String = _errorImageSrc!.split(',')[1];
        final bytes = base64Decode(base64String);

        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.contain,
        );
      }
    } catch (e) {
      // Base64 디코딩 실패 시 기본 아이콘 표시
    }

    // 폴백: 기본 에러 아이콘
    return Icon(
      Icons.broken_image,
      size: (widget.width != null && widget.height != null)
          ? (widget.width! < widget.height! ? widget.width! : widget.height!) * 0.5
          : 44,
      color: Colors.grey[400],
    );
  }
}
