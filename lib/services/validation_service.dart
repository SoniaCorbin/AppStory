class ValidationService {
  // Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  // Mot de passe
  static String? validatePassword(String? value) {
    if(value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    return null;
  }

  // Nom/titre — sanitize les caracteres dangereux
  static String sanitizeText(String value, {int maxLength = 255}) {
    return value
        .trim()
        .replaceAll(RegExp(r'[<>"\\/]'), '')
        .substring(0, value.trim().length.clamp(0, maxLength));
  }

  // Contenu long (histoire, page)
  static String sanitizeContent(String value, {int maxLength = 50000}) {
   return value
       .trim()
       .substring(0, value.trim().length.clamp(0, maxLength));
  }

  // Titre d'histoire
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Titre requis';
    if (value.trim().length > 100) return 'Titre trop long (max 100)';
    return null;
  }

  // Tags
  static List<String> sanitizeTags(List<String> tags) {
    return tags
        .map((t) => sanitizeText(t, maxLength: 30))
        .where((t) => t.isNotEmpty)
        .take(10)
        .toList();
  }
}