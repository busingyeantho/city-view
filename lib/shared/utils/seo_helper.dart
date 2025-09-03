import 'dart:html' as html;

void setPageSeo({required String title, String? description}) {
  html.document.title = title;
  if (description != null) {
    final meta = _ensureMeta('description');
    meta.content = description;
  }
}

html.MetaElement _ensureMeta(String name) {
  final existing = html.document.head!.querySelector('meta[name="$name"]') as html.MetaElement?;
  if (existing != null) return existing;
  final el = html.MetaElement()..name = name;
  html.document.head!.append(el);
  return el;
}


