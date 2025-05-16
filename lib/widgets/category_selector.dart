import 'package:flutter/material.dart';
import '../models/event.dart';

class CategorySelector extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Text(
            _selectedCategory.isEmpty 
                ? 'All Categories' 
                : 'Category: $_selectedCategory',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              // All categories option
              _buildCategoryChip('', 'All'),
              
              // Individual category options
              ...EventCategories.getAll().map((category) {
                return _buildCategoryChip(category, category);
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : '';
          });
          widget.onCategorySelected(_selectedCategory);
        },
        backgroundColor: Colors.grey[200],
        selectedColor: category.isEmpty 
            ? Colors.blue 
            : _getCategoryColor(category),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.green;
      case 'Health':
        return Colors.red;
      case 'Shopping':
        return Colors.purple;
      case 'Social':
        return Colors.orange;
      case 'Study':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
