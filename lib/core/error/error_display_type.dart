enum ErrorDisplayType {
  snackbar,    // For quick notifications like login errors
  fullPage,    // For full page errors with retry option
  inline,      // For inline errors within forms
  dialog,      // For modal dialog errors
  none         // For errors that should be handled silently
} 