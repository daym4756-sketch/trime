import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

enum HairType { lurus, ikal, keriting, tipis, tebal, normal }

class HairRecommendation {
  final String styleName;
  final String description;
  final String whyItFits;
  final String imageUrl;
  final double matchScore;
  final double estimatedPriceLow;
  final double estimatedPriceHigh;
  final int estimatedMinutes;
  final List<String> suitableHairTypes;
  final String difficultyLevel;

  const HairRecommendation({
    required this.styleName,
    required this.description,
    required this.whyItFits,
    required this.imageUrl,
    required this.matchScore,
    required this.estimatedPriceLow,
    required this.estimatedPriceHigh,
    required this.estimatedMinutes,
    required this.suitableHairTypes,
    required this.difficultyLevel,
  });

  factory HairRecommendation.fromJson(Map<String, dynamic> json) {
    return HairRecommendation(
      styleName: json['style_name'] as String? ?? json['styleName'] as String? ?? 'Unknown Style',
      description: json['description'] as String? ?? '',
      whyItFits: json['why_it_fits'] as String? ?? json['whyItFits'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      matchScore: (json['match_score'] as num? ?? json['matchScore'] as num? ?? 0.0).toDouble(),
      estimatedPriceLow: (json['estimated_price_low'] as num? ?? json['estimatedPriceLow'] as num? ?? 75000).toDouble(),
      estimatedPriceHigh: (json['estimated_price_high'] as num? ?? json['estimatedPriceHigh'] as num? ?? 150000).toDouble(),
      estimatedMinutes: json['estimated_minutes'] as int? ?? json['estimatedMinutes'] as int? ?? 60,
      suitableHairTypes: (json['suitable_hair_types'] as List<dynamic>? ?? json['suitableHairTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      difficultyLevel: json['difficulty_level'] as String? ?? json['difficultyLevel'] as String? ?? 'Medium',
    );
  }
}

class FaceAnalysisResult {
  final String faceShape;
  final String faceDetails;
  final String hairType;
  final double confidence;
  final List<HairRecommendation> recommendations;

  const FaceAnalysisResult({
    required this.faceShape,
    required this.faceDetails,
    required this.hairType,
    required this.confidence,
    required this.recommendations,
  });

  factory FaceAnalysisResult.fromJson(Map<String, dynamic> json) {
    final recs = (json['recommendations'] as List<dynamic>? ?? [])
        .map((r) => HairRecommendation.fromJson(r as Map<String, dynamic>))
        .toList();
    return FaceAnalysisResult(
      faceShape: json['face_shape'] as String? ?? json['faceShape'] as String? ?? 'oval',
      faceDetails: json['face_details'] as String? ?? json['faceDetails'] as String? ?? '',
      hairType: json['hair_type'] as String? ?? json['hairType'] as String? ?? 'normal',
      confidence: (json['confidence'] as num? ?? 0.85).toDouble(),
      recommendations: recs,
    );
  }
}

String _hairTypeLabel(String type) {
  switch (type.toLowerCase()) {
    case 'lurus':
    case 'straight':
      return 'Lurus';
    case 'ikal':
    case 'wavy':
      return 'Ikal';
    case 'keriting':
    case 'curly':
      return 'Keriting';
    case 'tipis':
    case 'thin':
      return 'Tipis';
    case 'tebal':
    case 'thick':
      return 'Tebal';
    default:
      return 'Normal';
  }
}

String _faceDetailsFor(String faceShape) {
  switch (faceShape.toLowerCase()) {
    case 'oval':
      return 'Wajah Oval ditandai dengan panjang wajah sedikit lebih besar dari lebar dahi, dan rahang yang lembut meruncing. Ini adalah bentuk wajah ideal yang cocok dengan sebagian besar gaya rambut modern.';
    case 'round':
      return 'Wajah Bulat ditandai dengan lebar dan panjang wajah hampir sama, serta tulang pipi yang menonjol dan garis rahang yang melunak. Gaya rambut bertekstur di bagian atas dapat membuat wajah terlihat lebih tirus.';
    case 'square':
      return 'Wajah Kotak ditandai dengan rahang yang kuat dan tegas, dahi lebar dengan sudut yang jelas. Disarankan gaya dengan lapisan di samping untuk melembutkan garis rahang.';
    case 'heart':
      return 'Wajah Hati (Heart Shape) ditandai dengan dahi yang lebar dan dagu yang meruncing. Gaya rambut dengan volume di bagian bawah akan menyeimbangkan bentuk wajah.';
    case 'oblong':
    case 'long':
      return 'Wajah Panjang (Oblong) ditandai dengan panjang wajah jauh lebih besar dari lebar dahi. Gaya rambut dengan volume di sisi dapat membuat wajah terlihat lebih proporsional.';
    case 'diamond':
      return 'Wajah Belah Ketupat (Diamond) ditandai dengan tulang pipi yang lebar dan dahi serta dagu yang lebih sempit. Gaya layer panjang akan memberikan keseimbangan.';
    case 'triangle':
      return 'Wajah Segitiga (Triangle) ditandai dengan rahang yang lebih lebar dari dahi. Gaya dengan volume di bagian atas akan menyeimbangkan bagian rahang yang kuat.';
    default:
      return 'Bentuk wajah ini memiliki proporsi menarik yang dapat diakomodasi dengan berbagai gaya rambut. Konsultasikan dengan kapster pilihanmu untuk hasil terbaik.';
  }
}

List<HairRecommendation> _generateRecommendations(String faceShape, String hairType) {
  String image(String style) =>
      'https://core-normal.traeapi.us/api/ide/v1/text_to_image?prompt=${Uri.encodeComponent('Professional male hair model with $style haircut, $faceShape face shape, highly detailed realistic portrait, 8k resolution, barbershop lighting, high contrast')}&image_size=square_hd';

  final f = faceShape.toLowerCase();
  final base = <HairRecommendation>[
    HairRecommendation(
      styleName: 'Classic Pompadour',
      description: 'Gaya rambut klasik dengan volume tinggi di bagian depan dan samping yang rapi.',
      whyItFits:
          f.contains('round') || f.contains('square')
              ? 'Volume tinggi di bagian atas membuat wajah bulat/kotak terlihat lebih proporsional dan tegas.'
              : 'Gaya klasik yang selalu elegan dan cocok untuk hampir semua bentuk wajah.',
      imageUrl: image('Classic Pompadour'),
      matchScore: f.contains('square') || f.contains('round') ? 0.94 : 0.85,
      estimatedPriceLow: 100000,
      estimatedPriceHigh: 180000,
      estimatedMinutes: 75,
      suitableHairTypes: ['Tebal', 'Lurus', 'Normal'],
      difficultyLevel: 'Tinggi',
    ),
    HairRecommendation(
      styleName: 'Side Part Fade',
      description: 'Potongan fade bersih di sisi dengan garis belahan yang jelas di salah satu sisi.',
      whyItFits:
          f.contains('round')
              ? 'Belahan samping dan volume di atas menambah dimensi vertikal pada wajah bulat.'
              : f.contains('heart')
                  ? 'Gaya ini menyeimbangkan dahi yang lebar dengan garis rahang yang meruncing.'
                  : 'Potongan bersih dan rapi yang cocok untuk tampilan formal maupun kasual.',
      imageUrl: image('Side Part Fade'),
      matchScore: f.contains('round') || f.contains('heart') ? 0.95 : 0.88,
      estimatedPriceLow: 85000,
      estimatedPriceHigh: 140000,
      estimatedMinutes: 60,
      suitableHairTypes: ['Lurus', 'Normal', 'Tebal'],
      difficultyLevel: 'Sedang',
    ),
    HairRecommendation(
      styleName: 'Textured Undercut',
      description: 'Bagian samping dan belakang sangat pendek, bagian atas dibiarkan panjang dengan tekstur natural.',
      whyItFits:
          f.contains('square') || f.contains('triangle')
              ? 'Panjang di bagian atas dan pendek di samping melembutkan garis rahang yang tegas.'
              : 'Gaya modern yang low maintenance dan tetap stylish sehari-hari.',
      imageUrl: image('Textured Undercut'),
      matchScore: f.contains('square') ? 0.96 : 0.87,
      estimatedPriceLow: 90000,
      estimatedPriceHigh: 160000,
      estimatedMinutes: 70,
      suitableHairTypes: ['Tebal', 'Ikal', 'Keriting'],
      difficultyLevel: 'Sedang',
    ),
    HairRecommendation(
      styleName: 'Modern Quiff',
      description: 'Perpaduan pompadour modern dengan tekstur messy tapi tetap teratur.',
      whyItFits:
          f.contains('oblong') || f.contains('long')
              ? 'Volume di sisi-sisi membuat wajah panjang terlihat lebih penuh dan seimbang.'
              : 'Gaya dinamis yang cocok untuk anak muda aktif dan ingin tampil beda.',
      imageUrl: image('Modern Quiff'),
      matchScore: f.contains('oblong') || f.contains('long') ? 0.93 : 0.86,
      estimatedPriceLow: 110000,
      estimatedPriceHigh: 190000,
      estimatedMinutes: 80,
      suitableHairTypes: ['Lurus', 'Normal', 'Tebal'],
      difficultyLevel: 'Tinggi',
    ),
    HairRecommendation(
      styleName: 'French Crop',
      description: 'Potongan pendek dengan fringe (poni) rapi di dahi dan tekstur halus di bagian atas.',
      whyItFits:
          f.contains('diamond') || f.contains('oval')
              ? 'Fringe menyamarkan dahi lebar sementara potongan rapi menonjolkan struktur wajah.'
              : 'Perawatan super mudah, cepat styling dan selalu fresh kapan saja.',
      imageUrl: image('French Crop'),
      matchScore: f.contains('diamond') || f.contains('oval') ? 0.92 : 0.84,
      estimatedPriceLow: 70000,
      estimatedPriceHigh: 110000,
      estimatedMinutes: 45,
      suitableHairTypes: ['Lurus', 'Tipis', 'Normal'],
      difficultyLevel: 'Rendah',
    ),
  ];
  base.sort((a, b) => b.matchScore.compareTo(a.matchScore));
  return base.sublist(0, 5);
}

class AIService {
  static const String baseUrl = 'http://192.168.1.6:8001';

  Future<Map<String, dynamic>> analyzeFaceShape(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze/face-shape'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final faceShape = (data['face_shape'] ?? 'oval').toString().toLowerCase();
        final hairTypeRaw = (data['hair_type'] ?? 'normal').toString().toLowerCase();
        final hairType = _hairTypeLabel(hairTypeRaw);
        final recommendations = _generateRecommendations(faceShape, hairType);
        return {
          'status': 'success',
          'face_shape': faceShape,
          'faceShape': faceShape,
          'face_details': _faceDetailsFor(faceShape),
          'faceDetails': _faceDetailsFor(faceShape),
          'hair_type': hairType,
          'hairType': hairType,
          'confidence': (data['confidence'] as num? ?? 0.86).toDouble(),
          'recommendations':
              recommendations.map((r) => {
                    'styleName': r.styleName,
                    'style_name': r.styleName,
                    'description': r.description,
                    'why_it_fits': r.whyItFits,
                    'whyItFits': r.whyItFits,
                    'image_url': r.imageUrl,
                    'imageUrl': r.imageUrl,
                    'match_score': r.matchScore,
                    'matchScore': r.matchScore,
                    'estimated_price_low': r.estimatedPriceLow,
                    'estimatedPriceLow': r.estimatedPriceLow,
                    'estimated_price_high': r.estimatedPriceHigh,
                    'estimatedPriceHigh': r.estimatedPriceHigh,
                    'estimated_minutes': r.estimatedMinutes,
                    'estimatedMinutes': r.estimatedMinutes,
                    'suitable_hair_types': r.suitableHairTypes,
                    'suitableHairTypes': r.suitableHairTypes,
                    'difficulty_level': r.difficultyLevel,
                    'difficultyLevel': r.difficultyLevel,
                  }).toList(),
        };
      } else {
        return {
          'status': 'failed',
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      final faceShape = 'oval';
      final hairType = 'Normal';
      final recommendations = _generateRecommendations(faceShape, hairType);
      return {
        'status': 'success',
        'face_shape': faceShape,
        'faceShape': faceShape,
        'face_details': _faceDetailsFor(faceShape),
        'faceDetails': _faceDetailsFor(faceShape),
        'hair_type': hairType,
        'hairType': hairType,
        'confidence': 0.82,
        'recommendations':
            recommendations.map((r) => {
                  'styleName': r.styleName,
                  'style_name': r.styleName,
                  'description': r.description,
                  'why_it_fits': r.whyItFits,
                  'whyItFits': r.whyItFits,
                  'image_url': r.imageUrl,
                  'imageUrl': r.imageUrl,
                  'match_score': r.matchScore,
                  'matchScore': r.matchScore,
                  'estimated_price_low': r.estimatedPriceLow,
                  'estimatedPriceLow': r.estimatedPriceLow,
                  'estimated_price_high': r.estimatedPriceHigh,
                  'estimatedPriceHigh': r.estimatedPriceHigh,
                  'estimated_minutes': r.estimatedMinutes,
                  'estimatedMinutes': r.estimatedMinutes,
                  'suitable_hair_types': r.suitableHairTypes,
                  'suitableHairTypes': r.suitableHairTypes,
                  'difficulty_level': r.difficultyLevel,
                  'difficultyLevel': r.difficultyLevel,
                }).toList(),
        'note': 'Offline mode: demo recommendations (connection failed: $e)',
      };
    }
  }
}
