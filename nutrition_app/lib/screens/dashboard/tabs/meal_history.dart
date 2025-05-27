// import 'package:flutter/material.dart';
// import 'package:nutrition_app/utils/AppColor.dart';
// import 'package:google_fonts/google_fonts.dart';

// class MealHistoryTab extends StatelessWidget {
//   const MealHistoryTab({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Meal History',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         automaticallyImplyLeading: false, // This disables the back button

//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () {
//               // Show filter options
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Date Range Selector
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'March 18 - March 24',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w500,
//                         color: textPrimaryColor,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.calendar_today),
//                       onPressed: () {
//                         // Show date picker
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Nutrition Summary
//             Text(
//               'Nutrition Summary',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: textPrimaryColor,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     _buildNutritionSummaryItem(
//                       label: 'Average Daily Calories',
//                       value: '1,850',
//                       target: '2,000',
//                       color: primaryColor,
//                     ),
//                     const Divider(height: 24),
//                     _buildNutritionSummaryItem(
//                       label: 'Average Protein',
//                       value: '110g',
//                       target: '120g',
//                       color: successColor,
//                     ),
//                     const Divider(height: 24),
//                     _buildNutritionSummaryItem(
//                       label: 'Average Carbs',
//                       value: '220g',
//                       target: '200g',
//                       color: warningColor,
//                     ),
//                     const Divider(height: 24),
//                     _buildNutritionSummaryItem(
//                       label: 'Average Fat',
//                       value: '65g',
//                       target: '60g',
//                       color: accentColor,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Meal History List
//             Text(
//               'Meal History',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: textPrimaryColor,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: 7,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: Column(
//                     children: [
//                       ListTile(
//                         title: Text(
//                           _getDateString(index),
//                           style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         trailing: Text(
//                           '${1500 + (index * 100)} cal',
//                           style: GoogleFonts.poppins(
//                             color: primaryColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       _buildMealHistoryItem(
//                         mealType: 'Breakfast',
//                         mealName: 'Oatmeal with Berries',
//                         calories: '350',
//                         time: '8:00 AM',
//                       ),
//                       _buildMealHistoryItem(
//                         mealType: 'Lunch',
//                         mealName: 'Grilled Chicken Salad',
//                         calories: '450',
//                         time: '12:30 PM',
//                       ),
//                       _buildMealHistoryItem(
//                         mealType: 'Dinner',
//                         mealName: 'Salmon with Vegetables',
//                         calories: '550',
//                         time: '7:00 PM',
//                       ),
//                       _buildMealHistoryItem(
//                         mealType: 'Snack',
//                         mealName: 'Greek Yogurt with Nuts',
//                         calories: '200',
//                         time: '3:00 PM',
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNutritionSummaryItem({
//     required String label,
//     required String value,
//     required String target,
//     required Color color,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 color: textSecondaryColor,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '$value / $target',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.bold,
//                 color: textPrimaryColor,
//               ),
//             ),
//           ],
//         ),
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Icon(
//               Icons.check_circle,
//               color: color,
//               size: 24,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMealHistoryItem({
//     required String mealType,
//     required String mealName,
//     required String calories,
//     required String time,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16.0,
//         vertical: 8.0,
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: primaryColor,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   mealType,
//                   style: GoogleFonts.poppins(
//                     color: textSecondaryColor,
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   mealName,
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 time,
//                 style: GoogleFonts.poppins(
//                   color: textSecondaryColor,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 '$calories cal',
//                 style: GoogleFonts.poppins(
//                   color: primaryColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _getDateString(int index) {
//     final now = DateTime.now();
//     final date = now.subtract(Duration(days: 6 - index));
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
