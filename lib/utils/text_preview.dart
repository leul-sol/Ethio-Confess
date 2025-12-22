String textPreview(String text, int maxsize) {
  if (text.length > maxsize) {
    return text.substring(0, maxsize) + '...';
  }
  return text;
}
