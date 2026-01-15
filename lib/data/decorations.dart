import '../models/decoration_model.dart';

/// 사용 가능한 모든 장식 아이템
const List<Decoration> availableDecorations = [
  // 식물 (Plants)
  Decoration(
    id: 'seaweed1',
    name: '갈조류',
    type: DecorationType.plant,
    icon: '🌿',
    cost: 20,
    description: '흔들리는 갈색 해초',
    rarity: Rarity.common,
  ),
  Decoration(
    id: 'seaweed2',
    name: '초록 해초',
    type: DecorationType.plant,
    icon: '🪴',
    cost: 25,
    description: '싱싱한 초록 해초',
    rarity: Rarity.common,
  ),
  Decoration(
    id: 'kelp',
    name: '다시마',
    type: DecorationType.plant,
    icon: '🌱',
    cost: 30,
    description: '큰 다시마 숲',
    rarity: Rarity.rare,
  ),
  
  // 돌 (Stones)
  Decoration(
    id: 'small_rock',
    name: '작은 돌',
    type: DecorationType.stone,
    icon: '🪨',
    cost: 15,
    description: '부드러운 작은 돌',
    rarity: Rarity.common,
  ),
  Decoration(
    id: 'big_rock',
    name: '큰 바위',
    type: DecorationType.stone,
    icon: '🗿',
    cost: 40,
    description: '웅장한 바위',
    rarity: Rarity.rare,
  ),
  
  // 산호 (Corals)
  Decoration(
    id: 'coral_pink',
    name: '핑크 산호',
    type: DecorationType.coral,
    icon: '🪸',
    cost: 50,
    description: '아름다운 핑크색 산호',
    rarity: Rarity.rare,
  ),
  Decoration(
    id: 'coral_red',
    name: '빨간 산호',
    type: DecorationType.coral,
    icon: '🦞',
    cost: 60,
    description: '희귀한 빨간 산호',
    rarity: Rarity.epic,
  ),
  
  // 장식품 (Ornaments)
  Decoration(
    id: 'shell',
    name: '조개껍데기',
    type: DecorationType.ornament,
    icon: '🐚',
    cost: 10,
    description: '예쁜 조개껍데기',
    rarity: Rarity.common,
  ),
  Decoration(
    id: 'starfish',
    name: '불가사리',
    type: DecorationType.ornament,
    icon: '⭐',
    cost: 35,
    description: '다섯 개의 팔을 가진 불가사리',
    rarity: Rarity.rare,
  ),
  Decoration(
    id: 'treasure',
    name: '보물상자',
    type: DecorationType.ornament,
    icon: '💎',
    cost: 100,
    description: '신비로운 보물상자',
    rarity: Rarity.epic,
  ),
  Decoration(
    id: 'anchor',
    name: '앵커',
    type: DecorationType.ornament,
    icon: '⚓',
    cost: 80,
    description: '오래된 닻',
    rarity: Rarity.epic,
  ),
  Decoration(
    id: 'castle',
    name: '해저 성',
    type: DecorationType.ornament,
    icon: '🏰',
    cost: 200,
    description: '전설의 해저 성',
    rarity: Rarity.legendary,
  ),
];
