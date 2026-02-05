/// Centralized app strings to avoid hardcoded text throughout the codebase.
/// This enables easier maintenance and future internationalization.
class AppStrings {
  AppStrings._();

  // App & Screen Titles
  static const String appTitle = 'ImageFlow';
  static const String homeScreenTitle = 'ImageFlow';
  static const String detailScreenTitle = 'Detail';
  static const String faceResultScreenTitle = 'Face Result';
  static const String pdfCreatedScreenTitle = 'PDF Created';

  // Toast Messages
  static const String itemDeleted = 'Item deleted';
  static const String failedToDeleteItem = 'Failed to delete item.';
  static const String imageProcessedSuccessfully =
      'Image processed successfully';
  static const String failedToSaveImagePdf =
      'Failed to save image/PDF. Please try again.';
  static const String noFacesDetected =
      'No faces detected. Try a clearer photo with visible faces.';
  static const String fileMissingRemoved =
      'This file is missing on disk. The item was removed from history.';

  // Dialog Titles & Content
  static const String deleteDialogTitle = 'Delete';
  static const String deleteDialogContent = 'Remove this item from history?';
  static const String permissionRequiredTitle = 'Permission required';

  // Dialog Actions
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String openSettings = 'Open Settings';
  static const String done = 'Done';

  // Source Selection
  static const String chooseSource = 'Choose Source';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';

  // Loading Messages
  static const String loading = 'Loading...';
  static const String preparing = 'Preparing...';
  static const String processing = 'Processing...';

  // Processing Steps
  static const String initializing = 'Initializing...';
  static const String detectingContent = 'Detecting content...';
  static const String detectingFaces = 'Detecting faces...';
  static const String detectingDocument = 'Detecting document...';
  static const String processingDocument = 'Processing document...';
  static const String creatingPdf = 'Creating PDF...';
  static const String saving = 'Saving...';

  // Empty States
  static const String noProcessedImagesYet = 'No processed images yet';

  // Document Labels
  static const String documentPrefix = 'Document';

  // Error Messages
  static const String itemNotFound = 'Item not found';
  static const String fileNotFound = 'File not found';
  static const String operationFailed = 'Operation failed. Please try again.';
  static const String failedToLoadImages =
      'Failed to load images. Please try again.';
  static const String failedToCaptureImage =
      'Failed to capture image. Please try again.';
  static const String atLeastOnePage = 'At least one page is required.';
  static const String multiPageDocumentsOnly =
      'Multi-page PDFs support documents only.';
  static const String pageAdded = 'Page added.';

  // PDF Labels
  static const String pdf = 'PDF';
  static const String openPdf = 'Open PDF';
  static const String pdfDocument = 'PDF Document';
  static const String exportPdf = 'Export PDF';
  static const String addPage = 'Add Page';
  static const String pagesLabel = 'Pages';
  static const String pageLabel = 'Page';
  static const String page = 'page';
  static const String pages = 'pages';

  // Image Labels
  static const String filtered = 'Filtered';
  static const String original = 'Original';
  static const String before = 'Before';
  static const String after = 'After';
  static const String blackAndWhite = 'B&W';
  static const String document = 'Document';

  // Metadata Labels
  static const String date = 'Date';
  static const String type = 'Type';
  static const String size = 'Size';

  // Processing Metadata
  static const String facesProcessed = 'faces:processed';
  static const String face = 'Face';
  static const String documentType = 'Document';
}
