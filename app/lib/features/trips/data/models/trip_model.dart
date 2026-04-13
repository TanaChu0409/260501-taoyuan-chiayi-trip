enum TripRole { owner, guest }

class ParkingSpot {
  const ParkingSpot({required this.name, required this.mapUrl});

  final String name;
  final String mapUrl;
}

class StopItem {
  const StopItem({
    required this.title,
    this.timeLabel,
    this.note,
    this.badge,
    this.mapUrl,
    this.isHighlight = false,
    this.parkingSpots = const [],
  });

  final String title;
  final String? timeLabel;
  final String? note;
  final String? badge;
  final String? mapUrl;
  final bool isHighlight;
  final List<ParkingSpot> parkingSpots;
}

class TripDay {
  const TripDay({
    required this.id,
    required this.label,
    required this.dateLabel,
    required this.subtitle,
    required this.stops,
  });

  final String id;
  final String label;
  final String dateLabel;
  final String subtitle;
  final List<StopItem> stops;
}

class TripSummary {
  const TripSummary({
    required this.id,
    required this.title,
    required this.dateRange,
    required this.role,
    required this.days,
  });

  final String id;
  final String title;
  final String dateRange;
  final TripRole role;
  final List<TripDay> days;

  int get stopCount => days.fold(0, (sum, day) => sum + day.stops.length);
}

const demoTrips = [
  TripSummary(
    id: 'taoyuan-chiayi-2026',
    title: '桃園嘉義行',
    dateRange: '2026/05/01 - 05/03',
    role: TripRole.owner,
    days: [
      TripDay(
        id: 'day1',
        label: '第一天',
        dateLabel: '5/1 Fri',
        subtitle: '桃園出發，家聚與晚餐後入住青埔商旅。',
        stops: [
          StopItem(title: '小寶貝家出發', timeLabel: '07:00', note: '早上出門，正式開始三天行程。'),
          StopItem(
            title: '吃早餐・星巴克天祥店',
            timeLabel: '08:00',
            note: '適合在這裡購買早餐。',
            badge: '導航',
            mapUrl: 'https://maps.app.goo.gl/PDWLQKYVTjHxmGfc6?g_st=ic',
            isHighlight: true,
          ),
          StopItem(
            title: '羽駿家',
            timeLabel: '12:00',
            note: '可先參考下方停車場資訊，抵達時可直接開啟導航。',
            parkingSpots: [
              ParkingSpot(
                name: '羽駿家停車場',
                mapUrl: 'https://maps.app.goo.gl/SK7134BKJG6K1aHeA',
              ),
            ],
          ),
          StopItem(title: '彌月活動', timeLabel: '13:00', badge: '活動'),
          StopItem(title: '一起吃晚餐・薄多義', timeLabel: '18:00', badge: '晚餐', mapUrl: 'https://maps.app.goo.gl/VmShjm65Gk856YRy8?g_st=ic', isHighlight: true),
          StopItem(title: '飯店 Check in・青埔商旅 CP-HOTEL', timeLabel: '20:00', badge: '住宿', mapUrl: 'https://maps.app.goo.gl/2cad3ebcL9NkCBRw8', isHighlight: true),
        ],
      ),
      TripDay(
        id: 'day2',
        label: '第二天',
        dateLabel: '5/2 Sat',
        subtitle: '退房後一路往南，晚上入住嘉義兆品酒店。',
        stops: [
          StopItem(title: '退房', timeLabel: '11:00'),
          StopItem(title: '華泰名品城', timeLabel: '12:00'),
          StopItem(title: '大溪老街', timeLabel: '13:00'),
          StopItem(title: '臨時到新竹家一趟', timeLabel: '14:30', badge: '彈性'),
          StopItem(title: '飯店 Check in・嘉義兆品酒店', timeLabel: '17:00', badge: '住宿', mapUrl: 'https://maps.app.goo.gl/Lqcgd2F6hd8nmgGYA', isHighlight: true),
          StopItem(title: '文化路夜市・樂檸漢堡', timeLabel: '18:00', badge: '晚間'),
        ],
      ),
      TripDay(
        id: 'day3',
        label: '第三天',
        dateLabel: '5/3 Sun',
        subtitle: '嘉義市區行程，含餐廳與附近停車場資訊。',
        stops: [
          StopItem(title: '退房', timeLabel: '12:00'),
          StopItem(
            title: '燒瓶子。大肆の鍋 嘉義店',
            timeLabel: '13:00',
            note: '用餐前可直接參考下方停車場資訊，減少抵達後找位時間。',
            badge: '午餐',
            mapUrl: 'https://maps.app.goo.gl/NeZXFbfmpUp5hDw48',
            isHighlight: true,
            parkingSpots: [
              ParkingSpot(name: 'CITY PARKING 城市車旅停車場 嘉義民權站', mapUrl: 'https://maps.app.goo.gl/NeZXFbfmpUp5hDw48'),
              ParkingSpot(name: 'CITY PARKING 城市車旅停車場 中正公園站', mapUrl: 'https://maps.app.goo.gl/Qg74Yfpb1eYNg2v6A'),
            ],
          ),
          StopItem(title: '土地公廟', timeLabel: '15:00'),
          StopItem(title: '檜意森活村', timeLabel: '15:30'),
          StopItem(title: '啟程回高雄', timeLabel: '17:00'),
        ],
      ),
    ],
  ),
  TripSummary(
    id: 'shared-family-trip',
    title: '家庭共遊（唯讀）',
    dateRange: '2026/06/14 - 06/15',
    role: TripRole.guest,
    days: [
      TripDay(
        id: 'shared-day1',
        label: '第一天',
        dateLabel: '6/14 Sun',
        subtitle: '透過邀請碼加入的唯讀旅程。',
        stops: [
          StopItem(title: '集合出發', timeLabel: '09:00', badge: '集合'),
          StopItem(title: '午餐餐廳', timeLabel: '12:00', badge: '午餐', isHighlight: true),
          StopItem(title: '飯店 Check in', timeLabel: '16:00', badge: '住宿'),
        ],
      ),
    ],
  ),
];
