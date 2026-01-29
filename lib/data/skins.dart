import '../models/skin_model.dart';

/// 사용 가능한 모든 스킨 테마
const List<Skin> availableSkins = [
  // 기본 스킨
  Skin(
    id: 'skin_default',
    name: '기본 물고기',
    icon: '🐠',
    cost: 0,
    description: '기본 제공 물고기 스킨',
    rarity: SkinRarity.common,
    color: '#FFD700',
  ),
  
  // 일반 레어 스킨
  Skin(
    id: 'skin_goldfish',
    icon: '🐟',
    name: '금색석',
    cost: 150,
    description: '반짝이는 금색 비늘',
    rarity: SkinRarity.uncommon,
    color: '#FFD700',
  ),
  Skin(
    id: 'skin_stripedfish',
    icon: '🦓',
    name: '줄무늬 물고기',
    cost: 120,
    description: '아프리카 스타일 줄무늬',
    rarity: SkinRarity.uncommon,
    color: '#FFFFFF',
  ),
  
  // 레어 스킨
  Skin(
    id: 'skin_neonparty',
    icon: '💖',
    name: '네온 파티',
    cost: 200,
    description: '형형색색한 네온 불빛',
    rarity: SkinRarity.rare,
    color: '#FF1493',
  ),
  Skin(
    id: 'skin_oceanboss',
    icon: '🐳',
    name: '해적 선장',
    cost: 180,
    description: '용감한 해적 물고기',
    rarity: SkinRarity.rare,
    color: '#2C3E50',
  ),
  
  // 에픽 스킨
  Skin(
    id: 'skin_phoenix',
    icon: '🔥',
    name: '불사조',
    cost: 300,
    description: '타오르는 불사조의 모습',
    rarity: SkinRarity.epic,
    color: '#FF4500',
  ),
  Skin(
    id: 'skin_crystal',
    icon: '💎',
    name: '크리스탈',
    cost: 280,
    description: '반짝이는 다이아몬드 물고기',
    rarity: SkinRarity.epic,
    color: '#00CED1',
  ),
  
  // 레전더리 스킨
  Skin(
    id: 'skin_galaxy',
    icon: '🌌',
    name: '갤럭시',
    cost: 500,
    description: '우주의 신비로운 빛',
    rarity: SkinRarity.legendary,
    color: '#4B0082',
  ),
  Skin(
    id: 'skin_dragon',
    icon: '🐉',
    name: '드래곤',
    cost: 480,
    description: '전설의 드래곤',
    rarity: SkinRarity.legendary,
    color: '#FFD700',
  ),
];
