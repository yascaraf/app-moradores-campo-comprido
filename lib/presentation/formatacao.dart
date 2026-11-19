String doisDigitos(int n) => n.toString().padLeft(2, '0');

String formatarData(DateTime d) =>
    '${doisDigitos(d.day)}/${doisDigitos(d.month)}/${d.year}';

String formatarHora(DateTime d) =>
    '${doisDigitos(d.hour)}:${doisDigitos(d.minute)}';
    