import 'package:flutter/material.dart';

class TempCourse {
  String name;
  int section;
  String description;
  String location;
  List<List<int>> classSections;
  Color color;

  TempCourse(this.name, this.section, this.description, this.location,
      this.classSections, this.color);
}