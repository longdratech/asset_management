import 'package:flutter/material.dart';

import '../constants/bookings_filter.dart';
import '../enums/filter_booking.dart';
import '../models/filter.dart';

class NewestFilter extends StatefulWidget {
  ValueChanged<BookingOrderBy> onChanged;

  NewestFilter({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<NewestFilter> createState() => _NewestFilterState();
}

class _NewestFilterState extends State<NewestFilter> {
  Filter _filterItem = bookingFilters[0];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Filter>(
      value: _filterItem,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (Filter? value) {
        // This is called when the user selects an item.
        if(value != null) {
          setState(() {
            _filterItem = value;
          });

          widget.onChanged(_filterItem.value);
        }
      },
      items: bookingFilters.map<DropdownMenuItem<Filter>>((Filter filter) {
        return DropdownMenuItem<Filter>(
          value: filter,
          child: Text(filter.label),
        );
      }).toList(),
    );
  }
}
