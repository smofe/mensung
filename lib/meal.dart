class Meal {
  String name;
  String notes;
  double rating;
  DateTime createdAt;

  Meal(this.name, this.rating) {
    this.createdAt = DateTime.now();
  }

  Meal.withNotes(this.name, this.rating, this.notes) {
    this.createdAt = DateTime.now();
  }
}