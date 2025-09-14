import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'api_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int showId;
  final int selectedUserId;

  const SeatSelectionScreen({
    super.key,
    required this.showId,
    required this.selectedUserId,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late Future<Map<String, dynamic>> futureSeatData;
  List<String> _selectedSeats = [];
  Map<String, dynamic> _realtimeSeatStatus = {};
  late WebSocketChannel _channel;

  final int rows = 10;
  final int columns = 10;
  final int maxSeats = 6;
  
  @override
  void initState() {
    super.initState();
    
    futureSeatData = ApiService().getSeatsForShow(widget.showId);
    
    // Initialize WebSocket connection
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080'),
    );

    // Listen for real-time seat updates
    _channel.stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      if (data['showId'] == widget.showId.toString()) {
        setState(() {
          // Update the local map with the real-time status
          _realtimeSeatStatus[data['seat']] = {
            'status': data['status'],
            'userId': data['userId'],
          };
        });
      }
    });
  }

  @override
  void dispose() {
    for (var seat in _selectedSeats) {
      _unblockSeat(seat);
    }
    _channel.sink.close();
    super.dispose();
  }

  String getSeatLabel(int row, int col) {
    String rowLetter = String.fromCharCode('A'.codeUnitAt(0) + row);
    return '$rowLetter${col + 1}';
  }


  void _blockSeat(String seatLabel) {
    final message = jsonEncode({
      'action': 'block',
      'showId': widget.showId.toString(),
      'seat': seatLabel,
      'userId': widget.selectedUserId.toString(),
    });
    _channel.sink.add(message);
  }


  void _unblockSeat(String seatLabel) {
    final message = jsonEncode({
      'action': 'unblock',
      'showId': widget.showId.toString(),
      'seat': seatLabel,
      'userId': widget.selectedUserId.toString(),
    });
    _channel.sink.add(message);
  }

  void toggleSeat(String seatLabel, List<String> bookedSeats) {
    
    final realtimeStatus = _realtimeSeatStatus[seatLabel];
    bool isBlockedByOther = realtimeStatus != null && realtimeStatus['userId'] != widget.selectedUserId.toString();
    
    if (bookedSeats.contains(seatLabel) || isBlockedByOther) {
      return;
    }
    
    if (_selectedSeats.contains(seatLabel)) {
      _selectedSeats.remove(seatLabel);
      _unblockSeat(seatLabel);
    } else {
      if (_selectedSeats.length < maxSeats) {
        _selectedSeats.add(seatLabel);
        _blockSeat(seatLabel);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only book a maximum of 6 seats.')),
        );
      }
    }
  }

  void bookSeats() async {
    if (_selectedSeats.isEmpty) {
      return;
    }
    bool success = await ApiService().bookSeats(widget.selectedUserId, widget.showId, _selectedSeats);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Successful!')),
      );
      
      for (var seat in _selectedSeats) {
        _unblockSeat(seat);
      }
      _selectedSeats.clear();
      setState(() {});
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Seats'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureSeatData,
        builder: (context, snapshot) {
          final List<String> bookedSeats = (snapshot.hasData && snapshot.data!['booked_seats'] != null)
              ? List<String>.from(snapshot.data!['booked_seats'])
              : [];
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Text(
                    'SCREEN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: rows * columns,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemBuilder: (context, index) {
                      final row = index ~/ columns;
                      final col = index % columns;
                      final seatLabel = getSeatLabel(row, col);

                      
                      bool isBooked = bookedSeats.contains(seatLabel);
                      bool isSelected = _selectedSeats.contains(seatLabel);
                      bool isBlockedByOther = false;
                      final realtimeStatus = _realtimeSeatStatus[seatLabel];
                      if (realtimeStatus != null) {
                        isBlockedByOther = realtimeStatus['userId'] != widget.selectedUserId.toString();
                      }
                      
                      Color seatColor;

                      if (isBooked) {
                        seatColor = Colors.grey;
                      } else if (isBlockedByOther) {
                        seatColor = Colors.red;
                      } else if (isSelected) {
                        seatColor = Colors.blue;
                      } else {
                        seatColor = Colors.green;
                      }

                      return InkWell(
                        onTap: () => toggleSeat(seatLabel, bookedSeats),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: seatColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            seatLabel,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSeatStatus(Colors.green, 'Available'),
                    const SizedBox(width: 20),
                    _buildSeatStatus(Colors.blue, 'Selected'),
                    const SizedBox(width: 20),
                    _buildSeatStatus(Colors.red, 'Blocked'),
                    const SizedBox(width: 20),
                    _buildSeatStatus(Colors.grey, 'Booked'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectedSeats.isEmpty ? null : bookSeats,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Book ${_selectedSeats.length} Seat(s)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeatStatus(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
