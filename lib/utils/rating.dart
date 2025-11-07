String getRatingLabel(int rating) {
  switch (rating) {
    case 5:
      return 'Outstanding';
    case 4:
      return 'Very Satisfactory';
    case 3:
      return 'Satisfactory';
    case 2:
      return 'Fair';
    case 1:
      return 'Poor';
    default:
      return 'Not rated';
  }
}
