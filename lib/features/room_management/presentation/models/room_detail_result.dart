class RoomDetailResult {
  final bool isDeleted;
  final int newDeviceCount;
  final int newOnlineCount;
  final String newName;

  const RoomDetailResult({
    this.isDeleted = false,
    required this.newDeviceCount,
    required this.newOnlineCount,
    required this.newName,
  });
}
