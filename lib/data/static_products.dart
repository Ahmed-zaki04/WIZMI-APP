class BrandModel {
  final String id;
  final String name;
  final String logoUrl;
  final String segment; // 'B' or 'C'

  const BrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.segment,
  });
}

class PartModel {
  final String id;
  final String brandId;
  final String name;
  final String description;
  final String category;
  final int price;

  const PartModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
  });
}

class SparePartsData {
  static const List<BrandModel> brands = [
    // ── B-Segment (Economy) ────────────────────────────────────────────────
    BrandModel(
      id: 'toyota',
      name: 'Toyota',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Toyota_carlogo.svg',
      segment: 'B',
    ),
    BrandModel(
      id: 'hyundai',
      name: 'Hyundai',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/0e/Hyundai_Motor_Company_logo.svg',
      segment: 'B',
    ),
    BrandModel(
      id: 'kia',
      name: 'Kia',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/13/Kia-logo.png',
      segment: 'B',
    ),
    BrandModel(
      id: 'chevrolet',
      name: 'Chevrolet',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/1e/Chevrolet_logo.svg',
      segment: 'B',
    ),
    // ── C-Segment (Premium/European) ───────────────────────────────────────
    BrandModel(
      id: 'bmw',
      name: 'BMW',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg',
      segment: 'C',
    ),
    BrandModel(
      id: 'mercedes',
      name: 'Mercedes-Benz',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/90/Mercedes-Logo.svg',
      segment: 'C',
    ),
    BrandModel(
      id: 'audi',
      name: 'Audi',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c0/Audi-Logo_2016.svg',
      segment: 'C',
    ),
    BrandModel(
      id: 'volkswagen',
      name: 'Volkswagen',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/6/6d/Volkswagen_logo_2019.svg',
      segment: 'C',
    ),
  ];

  static Map<String, List<PartModel>> get partsByBrand => {
    // ── Toyota (Corolla, Camry, Yaris, Fortuner) ───────────────────────────
    'toyota': [
      const PartModel(id: 'toy_01', brandId: 'toyota', name: 'Engine Oil Filter', description: 'Genuine OEM oil filter — fits Corolla, Camry, Yaris', category: 'Engine', price: 150),
      const PartModel(id: 'toy_02', brandId: 'toyota', name: 'Air Filter', description: 'High-flow air filter — all 1.6 & 2.0 L engines', category: 'Engine', price: 250),
      const PartModel(id: 'toy_03', brandId: 'toyota', name: 'Front Brake Pads', description: 'Ceramic front brake pads — set of 4', category: 'Brakes', price: 850),
      const PartModel(id: 'toy_04', brandId: 'toyota', name: 'Spark Plugs Set ×4', description: 'NGK iridium spark plugs — improved fuel efficiency', category: 'Engine', price: 400),
      const PartModel(id: 'toy_05', brandId: 'toyota', name: 'Timing Belt', description: 'OEM timing belt — replace every 60,000 km', category: 'Engine', price: 1200),
      const PartModel(id: 'toy_06', brandId: 'toyota', name: 'Alternator', description: 'Remanufactured alternator 80A — Corolla & Camry', category: 'Electrical', price: 3500),
      const PartModel(id: 'toy_07', brandId: 'toyota', name: 'Water Pump', description: 'Aluminium water pump with gasket — 1ZZ & 2ZZ engines', category: 'Cooling', price: 1800),
      const PartModel(id: 'toy_08', brandId: 'toyota', name: 'Radiator', description: 'Full aluminium radiator — Corolla 2002–2020', category: 'Cooling', price: 3200),
    ],

    // ── Hyundai (Accent, i10, i20, Elantra, Tucson) ────────────────────────
    'hyundai': [
      const PartModel(id: 'hyu_01', brandId: 'hyundai', name: 'Engine Oil Filter', description: 'Genuine oil filter — fits Accent, i10, i20, Elantra', category: 'Engine', price: 130),
      const PartModel(id: 'hyu_02', brandId: 'hyundai', name: 'Air Filter', description: 'Premium air filter — 1.4 & 1.6 L engines', category: 'Engine', price: 220),
      const PartModel(id: 'hyu_03', brandId: 'hyundai', name: 'Front Brake Pads', description: 'Semi-metallic front brake pads — set of 4', category: 'Brakes', price: 750),
      const PartModel(id: 'hyu_04', brandId: 'hyundai', name: 'Spark Plugs Set ×4', description: 'Bosch platinum spark plugs — improved cold-start', category: 'Engine', price: 350),
      const PartModel(id: 'hyu_05', brandId: 'hyundai', name: 'Serpentine Belt', description: 'Drive belt — Accent & Elantra 2010–2022', category: 'Engine', price: 450),
      const PartModel(id: 'hyu_06', brandId: 'hyundai', name: 'Alternator', description: 'Rebuilt alternator 90A — i10, i20, Accent', category: 'Electrical', price: 3200),
      const PartModel(id: 'hyu_07', brandId: 'hyundai', name: 'AC Compressor', description: 'Original AC compressor — Elantra, Tucson', category: 'AC', price: 5500),
      const PartModel(id: 'hyu_08', brandId: 'hyundai', name: 'Fuel Pump', description: 'In-tank fuel pump — Accent & Elantra 1.6 L', category: 'Fuel', price: 2200),
    ],

    // ── Kia (Rio, Cerato, Sportage, Picanto) ──────────────────────────────
    'kia': [
      const PartModel(id: 'kia_01', brandId: 'kia', name: 'Engine Oil Filter', description: 'Genuine oil filter — Rio, Cerato, Picanto', category: 'Engine', price: 120),
      const PartModel(id: 'kia_02', brandId: 'kia', name: 'Air Filter', description: 'Performance air filter — 1.4 & 1.6 L engines', category: 'Engine', price: 200),
      const PartModel(id: 'kia_03', brandId: 'kia', name: 'Front Brake Pads', description: 'Ceramic brake pads front axle — set of 4', category: 'Brakes', price: 700),
      const PartModel(id: 'kia_04', brandId: 'kia', name: 'Spark Plugs Set ×4', description: 'Iridium spark plugs — fits Rio & Cerato', category: 'Engine', price: 320),
      const PartModel(id: 'kia_05', brandId: 'kia', name: 'Drive Shaft (Right)', description: 'CV axle right side — Cerato & Sportage', category: 'Drivetrain', price: 2500),
      const PartModel(id: 'kia_06', brandId: 'kia', name: 'Alternator', description: 'Rebuilt alternator 75A — Rio, Picanto', category: 'Electrical', price: 3000),
      const PartModel(id: 'kia_07', brandId: 'kia', name: 'Battery 60Ah', description: 'Maintenance-free 60Ah battery — all Kia models', category: 'Electrical', price: 1800),
    ],

    // ── Chevrolet (Optra, Spark, Captiva, Cruz) ───────────────────────────
    'chevrolet': [
      const PartModel(id: 'chev_01', brandId: 'chevrolet', name: 'Engine Oil Filter', description: 'Genuine oil filter — Optra, Spark, Cruz', category: 'Engine', price: 140),
      const PartModel(id: 'chev_02', brandId: 'chevrolet', name: 'Air Filter', description: 'High-flow air filter — 1.6 Optra & Cruz', category: 'Engine', price: 230),
      const PartModel(id: 'chev_03', brandId: 'chevrolet', name: 'Front Brake Pads', description: 'Semi-metallic front pads — set of 4, Optra', category: 'Brakes', price: 780),
      const PartModel(id: 'chev_04', brandId: 'chevrolet', name: 'Spark Plugs Set ×4', description: 'NGK standard spark plugs — Optra 1.8 L', category: 'Engine', price: 380),
      const PartModel(id: 'chev_05', brandId: 'chevrolet', name: 'Alternator', description: 'Rebuilt alternator 85A — Optra & Captiva', category: 'Electrical', price: 3800),
      const PartModel(id: 'chev_06', brandId: 'chevrolet', name: 'Power Steering Pump', description: 'Hydraulic power steering pump — Optra 2003–2010', category: 'Steering', price: 4500),
      const PartModel(id: 'chev_07', brandId: 'chevrolet', name: 'AC Compressor', description: 'OEM AC compressor — Captiva & Cruz 2.0 L', category: 'AC', price: 6000),
    ],

    // ── BMW (3 Series, 5 Series, X5) ──────────────────────────────────────
    'bmw': [
      const PartModel(id: 'bmw_01', brandId: 'bmw', name: 'Engine Oil Filter', description: 'Mann-Hummel oil filter — N46, N52, N54 engines', category: 'Engine', price: 350),
      const PartModel(id: 'bmw_02', brandId: 'bmw', name: 'Air Filter', description: 'OEM air filter — 3 Series (E90/F30) & 5 Series', category: 'Engine', price: 650),
      const PartModel(id: 'bmw_03', brandId: 'bmw', name: 'Front Brake Pads', description: 'Genuine Brembo front pads — 3 & 5 Series', category: 'Brakes', price: 2800),
      const PartModel(id: 'bmw_04', brandId: 'bmw', name: 'Spark Plugs Set ×4', description: 'Bosch Super Plus spark plugs — N42 & N46 engines', category: 'Engine', price: 1200),
      const PartModel(id: 'bmw_05', brandId: 'bmw', name: 'Timing Chain Kit', description: 'Complete chain kit with tensioner — N47 diesel', category: 'Engine', price: 8500),
      const PartModel(id: 'bmw_06', brandId: 'bmw', name: 'Alternator', description: 'Valeo alternator 150A — 5 Series F10 & E60', category: 'Electrical', price: 7500),
      const PartModel(id: 'bmw_07', brandId: 'bmw', name: 'Water Pump', description: 'Electromagnetic water pump — N52 & N54 engines', category: 'Cooling', price: 4500),
      const PartModel(id: 'bmw_08', brandId: 'bmw', name: 'VANOS Solenoid', description: 'Variable valve timing solenoid — N42, N46 inlet', category: 'Engine', price: 2800),
    ],

    // ── Mercedes-Benz (C-Class, E-Class, GLA) ─────────────────────────────
    'mercedes': [
      const PartModel(id: 'mer_01', brandId: 'mercedes', name: 'Engine Oil Filter', description: 'Mahle oil filter — M271, M272 & OM651 engines', category: 'Engine', price: 400),
      const PartModel(id: 'mer_02', brandId: 'mercedes', name: 'Air Filter', description: 'OEM air filter — C-Class (W204/W205) & E-Class', category: 'Engine', price: 750),
      const PartModel(id: 'mer_03', brandId: 'mercedes', name: 'Front Brake Pads', description: 'Genuine AMG-spec front pads — C & E-Class', category: 'Brakes', price: 3500),
      const PartModel(id: 'mer_04', brandId: 'mercedes', name: 'Spark Plugs Set ×4', description: 'NGK laser iridium — M271 & M274 petrol', category: 'Engine', price: 1800),
      const PartModel(id: 'mer_05', brandId: 'mercedes', name: 'Alternator', description: 'Bosch alternator 180A — E-Class W212 & W213', category: 'Electrical', price: 8000),
      const PartModel(id: 'mer_06', brandId: 'mercedes', name: 'Water Pump', description: 'OEM water pump with housing — M271 engine', category: 'Cooling', price: 5500),
      const PartModel(id: 'mer_07', brandId: 'mercedes', name: 'MAF Sensor', description: 'Mass air flow sensor — C-Class & GLA 2013–2022', category: 'Engine', price: 4200),
      const PartModel(id: 'mer_08', brandId: 'mercedes', name: 'Front Control Arm', description: 'Lower control arm with ball joint — W204 C-Class', category: 'Suspension', price: 3800),
    ],

    // ── Audi (A3, A4, A6, Q5) ─────────────────────────────────────────────
    'audi': [
      const PartModel(id: 'aud_01', brandId: 'audi', name: 'Engine Oil Filter', description: 'Mann oil filter — EA113, EA888 & TDI engines', category: 'Engine', price: 380),
      const PartModel(id: 'aud_02', brandId: 'audi', name: 'Air Filter', description: 'OEM air filter — A3, A4 (B8/B9) & Q5', category: 'Engine', price: 680),
      const PartModel(id: 'aud_03', brandId: 'audi', name: 'Front Brake Pads', description: 'Textar front brake pads — A4 B8 & A6 C7', category: 'Brakes', price: 3200),
      const PartModel(id: 'aud_04', brandId: 'audi', name: 'Timing Belt Kit', description: 'Complete belt kit with tensioner — 2.0 TDI', category: 'Engine', price: 9500),
      const PartModel(id: 'aud_05', brandId: 'audi', name: 'Alternator', description: 'Valeo alternator 140A — A4 & Q5 2.0 TFSI', category: 'Electrical', price: 7000),
      const PartModel(id: 'aud_06', brandId: 'audi', name: 'Water Pump', description: 'Thermostatic water pump — EA888 Gen3 engine', category: 'Cooling', price: 4800),
      const PartModel(id: 'aud_07', brandId: 'audi', name: 'Fuel Pump', description: 'High-pressure fuel pump — 2.0 TFSI direct injection', category: 'Fuel', price: 5200),
    ],

    // ── Volkswagen (Golf, Polo, Passat, Tiguan) ───────────────────────────
    'volkswagen': [
      const PartModel(id: 'vw_01', brandId: 'volkswagen', name: 'Engine Oil Filter', description: 'Mann oil filter — EA111, EA211 & EA888 engines', category: 'Engine', price: 290),
      const PartModel(id: 'vw_02', brandId: 'volkswagen', name: 'Air Filter', description: 'OEM air filter — Golf (Mk6/Mk7) & Polo', category: 'Engine', price: 520),
      const PartModel(id: 'vw_03', brandId: 'volkswagen', name: 'Front Brake Pads', description: 'TRW front brake pads — Golf & Passat B8', category: 'Brakes', price: 2200),
      const PartModel(id: 'vw_04', brandId: 'volkswagen', name: 'Timing Belt Kit', description: 'Complete kit with water pump — 2.0 TDI PD', category: 'Engine', price: 5500),
      const PartModel(id: 'vw_05', brandId: 'volkswagen', name: 'Alternator', description: 'Bosch alternator 120A — Golf & Passat 2.0 TSI', category: 'Electrical', price: 5500),
      const PartModel(id: 'vw_06', brandId: 'volkswagen', name: 'Ignition Coil Pack', description: 'OEM coil pack — Golf Mk5/Mk6 1.4 & 2.0 TSI', category: 'Engine', price: 850),
      const PartModel(id: 'vw_07', brandId: 'volkswagen', name: 'Throttle Body', description: 'Electronic throttle body — EA111 & EA211 engines', category: 'Engine', price: 3200),
    ],
  };
}
