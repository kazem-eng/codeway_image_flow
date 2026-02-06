import 'package:codeway_image_processing/base/mvvm_base/base_state.dart';
import 'package:codeway_image_processing/base/services/file_storage_service/i_file_storage_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/i_navigation_service.dart';
import 'package:codeway_image_processing/base/services/navigation_service/routes.dart';
import 'package:codeway_image_processing/base/services/file_open_service/i_file_open_service.dart';
import 'package:codeway_image_processing/base/services/toast_service/i_toast_service.dart';
import 'package:codeway_image_processing/features/image_processing/data/repositories/i_processed_image_repository.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_model.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_props.dart';
import 'package:codeway_image_processing/features/image_processing/utils/face_batch_metadata.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:get/get.dart';

class SummaryVM {
  SummaryVM({
    required INavigationService navigationService,
    required IProcessedImageRepository repository,
    required IFileStorageService fileStorageService,
    required IFileOpenService fileOpenService,
    this.closeOnEmpty = true,
  }) : _navigationService = navigationService,
       _repository = repository,
       _fileStorageService = fileStorageService,
       _fileOpenService = fileOpenService;

  final INavigationService _navigationService;
  final IProcessedImageRepository _repository;
  final IFileStorageService _fileStorageService;
  final IFileOpenService _fileOpenService;
  final bool closeOnEmpty;
  final IToastService _toastService = Get.find<IToastService>();

  final _state = const BaseState<SummaryModel>.success(
    SummaryModel(),
  ).obs;
  BaseState<SummaryModel> get state => _state.value;
  SummaryModel get model => _state.value.data ?? const SummaryModel();

  Future<void> init(SummaryProps props) async {
    _state.value = BaseState.loading(
      _buildInitialModel(props),
    );
    final resolved = await _resolveSummaryData(props);
    _state.value = BaseState.success(
      SummaryModel(
        faces: resolved.faces,
        documents: props.documents,
        selectedFaceIndex: 0,
        faceGroupId: props.faceGroupId ?? resolved.faceGroupEntity?.id,
        faceGroupEntity: resolved.faceGroupEntity,
      ),
    );
  }

  void selectFace(int index) {
    if (index < 0 || index >= model.faces.length) return;
    _state.value = BaseState.success(model.copyWith(selectedFaceIndex: index));
  }

  Future<void> openDocument(ProcessedImage image) async {
    try {
      await _fileOpenService.open(image.processedPath);
    } catch (_) {
      _toastService.show(AppStrings.fileNotFound, type: ToastType.error);
    }
  }

  Future<void> openDetail(ProcessedImage image) async {
    await _navigationService.goTo(
      Routes.detail,
      arguments: DetailProps(imageId: image.id),
    );
  }

  Future<void> done() async {
    await _navigationService.goBackUntil(Routes.home);
  }

  Future<void> deleteSelectedFace() async {
    await deleteFaceAt(model.selectedFaceIndex);
  }

  Future<void> deleteFaceAt(int index) async {
    final faces = List<SummaryFacePreview>.from(model.faces);
    final selected = _selectFaceForDeletion(faces, index);
    if (selected == null) return;
    await _deleteFaceImage(selected.image);

    faces.removeAt(index);
    final newIndex = faces.isEmpty ? 0 : index.clamp(0, faces.length - 1);

    final updatedGroup = await _updateGroupMetadata(faces);
    if (faces.isEmpty) {
      await _handleEmptyFaces(updatedGroup);
      return;
    }

    _state.value = BaseState.success(
      model.copyWith(
        faces: faces,
        selectedFaceIndex: newIndex,
        faceGroupEntity: updatedGroup ?? model.faceGroupEntity,
      ),
    );
  }

  SummaryModel _buildInitialModel(SummaryProps props) {
    return SummaryModel(
      faces: props.faces,
      documents: props.documents,
      selectedFaceIndex: 0,
      faceGroupId: props.faceGroupId,
      faceGroupEntity: props.faceGroupEntity,
    );
  }

  Future<_SummaryInitData> _resolveSummaryData(SummaryProps props) async {
    var faces = props.faces;
    var groupEntity = props.faceGroupEntity;
    if (groupEntity == null && props.faceGroupId != null) {
      await _repository.init();
      groupEntity = await _repository.getById(props.faceGroupId!);
    }
    if (faces.isEmpty && groupEntity != null) {
      final ids = FaceBatchMetadata.parseGroup(groupEntity.metadata);
      faces = await _loadFacePreviews(ids);
      groupEntity = await _maybeUpdateGroupMetadata(groupEntity, faces, ids);
    }
    return _SummaryInitData(faces: faces, faceGroupEntity: groupEntity);
  }

  Future<ProcessedImage?> _maybeUpdateGroupMetadata(
    ProcessedImage groupEntity,
    List<SummaryFacePreview> faces,
    List<String> ids,
  ) async {
    if (faces.isEmpty || faces.length == ids.length) return groupEntity;
    final updated = ProcessedImage(
      id: groupEntity.id,
      processingType: groupEntity.processingType,
      originalPath: groupEntity.originalPath,
      processedPath: groupEntity.processedPath,
      thumbnailPath: groupEntity.thumbnailPath,
      fileSize: groupEntity.fileSize,
      createdAt: groupEntity.createdAt,
      metadata: FaceBatchMetadata.group(
        faces.map((f) => f.image.id).toList(),
      ),
    );
    await _repository.add(updated);
    return updated;
  }

  SummaryFacePreview? _selectFaceForDeletion(
    List<SummaryFacePreview> faces,
    int index,
  ) {
    if (faces.isEmpty) return null;
    if (index < 0 || index >= faces.length) return null;
    return faces[index];
  }

  Future<void> _deleteFaceImage(ProcessedImage image) async {
    await _repository.init();
    await _fileStorageService.deleteProcessedImageFiles(image);
    await _repository.delete(image.id);
  }

  Future<void> _handleEmptyFaces(ProcessedImage? groupEntity) async {
    if (groupEntity != null) {
      await _fileStorageService.deleteProcessedImageFiles(groupEntity);
      await _repository.delete(groupEntity.id);
    }
    if (closeOnEmpty) {
      await done();
      return;
    }
    _state.value = BaseState.success(
      model.copyWith(
        faces: const [],
        selectedFaceIndex: 0,
        faceGroupEntity: null,
      ),
    );
  }

  Future<ProcessedImage?> _updateGroupMetadata(
    List<SummaryFacePreview> faces,
  ) async {
    final group = model.faceGroupEntity;
    if (group == null) return null;
    if (faces.isEmpty) return group;
    final first = faces.first.image;
    final totalSize =
        faces.fold<int>(0, (sum, item) => sum + (item.image.fileSize ?? 0));
    final ids = faces.map((f) => f.image.id).toList();
    final updated = ProcessedImage(
      id: group.id,
      processingType: group.processingType,
      originalPath: first.originalPath,
      processedPath: first.processedPath,
      thumbnailPath: first.thumbnailPath,
      fileSize: totalSize,
      createdAt: group.createdAt,
      metadata: FaceBatchMetadata.group(ids),
    );
    await _repository.add(updated);
    return updated;
  }

  Future<List<SummaryFacePreview>> _loadFacePreviews(
    List<String> ids,
  ) async {
    final result = <SummaryFacePreview>[];
    for (final id in ids) {
      final image = await _repository.getById(id);
      if (image == null) continue;
      try {
        final processed = await _fileStorageService.loadImage(
          image.processedPath,
        );
        final original = await _fileStorageService.loadImage(
          image.originalPath,
        );
        result.add(
          SummaryFacePreview(
            image: image,
            originalBytes: original,
            processedBytes: processed,
          ),
        );
      } catch (_) {
        // Skip missing files; they will be cleaned up on next delete.
      }
    }
    return result;
  }
}

class _SummaryInitData {
  const _SummaryInitData({required this.faces, required this.faceGroupEntity});

  final List<SummaryFacePreview> faces;
  final ProcessedImage? faceGroupEntity;
}
