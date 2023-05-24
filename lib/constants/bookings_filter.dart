import 'package:assets_management/enums/filter_booking.dart';

import '../models/filter.dart';

List<Filter> bookingFilters = [
  Filter("Mới nhất", BookingOrderBy.newest),
  Filter("Chưa trả", BookingOrderBy.notReturn),
];
