/// The canonical material-request units (admin-defined). Used by the supervisor's
/// submit form (unit dropdown). Order matches the business's list.
class MaterialUnits {
  const MaterialUnits._();

  static const List<String> all = [
    'CART.',
    "No's",
    'SET',
    'PCS',
    'SHEET',
    'BOX',
    'LTR',
    'PKT',
    'BANDAL',
    'MTR',
    'ROLL',
    'EF',
  ];
}
