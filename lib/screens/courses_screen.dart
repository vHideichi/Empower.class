import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> _cursos = [];
  bool _carregando = true;
  String _userTipo = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final tipo = prefs.getString('userTipo') ?? 'aluno';
    final cursos = await ApiService.getCursos();
    if (!mounted) return;
    setState(() {
      _userTipo = tipo;
      _cursos = cursos;
      _carregando = false;
    });
  }

  bool get _isProfessorOuAdmin => _userTipo == 'professor' || _userTipo == 'admin';

  void _abrirCriarCurso() {
    final tituloCtrl = TextEditingController();
    final descricaoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF081225),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)))),
            const SizedBox(height: 24),
            const Text("Criar Novo Curso", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _campo(tituloCtrl, "Título do curso"),
            const SizedBox(height: 12),
            _campo(descricaoCtrl, "Descrição do curso", linhas: 3),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (tituloCtrl.text.trim().isEmpty) return;
                  Navigator.pop(context);
                  await ApiService.createCurso({
                    'titulo': tituloCtrl.text.trim(),
                    'descricao': descricaoCtrl.text.trim(),
                  });
                  await _carregar();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Curso criado!'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Criar Curso", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirEditarCurso(Map<String, dynamic> curso) {
    final tituloCtrl = TextEditingController(text: curso['titulo'] ?? '');
    final descricaoCtrl = TextEditingController(text: curso['descricao'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF081225),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)))),
            const SizedBox(height: 24),
            const Text("Editar Curso", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _campo(tituloCtrl, "Título do curso"),
            const SizedBox(height: 12),
            _campo(descricaoCtrl, "Descrição do curso", linhas: 3),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (tituloCtrl.text.trim().isEmpty) return;
                  Navigator.pop(context);
                  await ApiService.updateCurso(curso['id'], {
                    'titulo': tituloCtrl.text.trim(),
                    'descricao': descricaoCtrl.text.trim(),
                  });
                  await _carregar();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Curso atualizado!'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Salvar Alterações", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String hint, {int linhas = 1}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF111C3D), borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: ctrl,
        maxLines: linhas,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _matricular(int cursoId) async {
    await ApiService.matricular(cursoId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Matriculado com sucesso!'), backgroundColor: Colors.green),
    );
  }

  void _deletarCurso(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111C3D),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: const Text('Deseja deletar este curso?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deletar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await ApiService.deleteCurso(id);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Curso removido.'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081225),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081225),
        elevation: 0,
        centerTitle: true,
        title: const Text("Cursos", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          if (_isProfessorOuAdmin)
            IconButton(
              onPressed: _abrirCriarCurso,
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Criar Curso',
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: _cursos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, color: Colors.white30, size: 64),
                          const SizedBox(height: 16),
                          const Text("Nenhum curso disponível", style: TextStyle(color: Colors.white54)),
                          if (_isProfessorOuAdmin) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _abrirCriarCurso,
                              icon: const Icon(Icons.add),
                              label: const Text("Criar primeiro curso"),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A6CFF)),
                            ),
                          ]
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cursos.length,
                      itemBuilder: (_, index) {
                        final curso = _cursos[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111C3D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 8,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xFF4A6CFF), Color(0xFF7B3FFF)]),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            curso['titulo'] ?? 'Sem título',
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (curso['publicado'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                            child: const Text("Publicado", style: TextStyle(color: Colors.green, fontSize: 11)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      curso['descricao'] ?? '',
                                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (_userTipo == 'aluno')
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _matricular(curso['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF4A6CFF),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: const Text("Matricular-se", style: TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        if (_isProfessorOuAdmin) ...[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _abrirEditarCurso(curso),
                                              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                              label: const Text("Editar", style: TextStyle(color: Colors.white)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF4A6CFF),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                          if (_userTipo == 'admin') ...[
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () => _deletarCurso(curso['id']),
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}