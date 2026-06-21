import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grupo_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/visao_estado.dart';
import '../widgets/banner_conexao.dart';
import 'grupo_home_screen.dart';

/// Tela inicial pos-login: saudacao e grupos de cuidado do usuario (UC002).
class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});
  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<GrupoProvider>().carregar());
  }

  Future<void> _sair() async {
    await context.read<SessionProvider>().sair();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _entrarConvite() async {
    final token = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Entrar com convite'),
        content: TextField(
          controller: token,
          decoration: const InputDecoration(labelText: 'Codigo do convite', prefixIcon: Icon(Icons.vpn_key)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entrar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final prov = context.read<GrupoProvider>();
    final sucesso = await prov.aceitarConvite(token.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sucesso ? 'Voce entrou no grupo!' : (prov.erro ?? 'Convite invalido'))),
    );
  }

  Future<void> _novoGrupo() async {
    final nome = TextEditingController();
    final idoso = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo grupo de cuidado'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome do grupo')),
          const SizedBox(height: 12),
          TextField(controller: idoso, decoration: const InputDecoration(labelText: 'Nome do idoso')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Criar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<GrupoProvider>().criar(nome.text.trim(), idoso.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<GrupoProvider>();
    final nome = context.read<SessionProvider>().nomeUsuario.split(' ').first;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoGrupo,
        icon: const Icon(Icons.add),
        label: const Text('Novo grupo'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cabecalho(context, nome, prov.grupos.length),
            Expanded(
              child: prov.carregando
                  ? const Carregando()
                  : (prov.erro != null && prov.grupos.isEmpty)
                      ? ErroView(mensagem: prov.erro!, aoTentar: () => prov.carregar())
                      : prov.grupos.isEmpty
                          ? EstadoVazio(
                              icone: Icons.diversity_3,
                              titulo: 'Nenhum grupo ainda',
                              descricao: 'Crie um grupo de cuidado para organizar rotinas, diario e relatorios do idoso.',
                              acaoRotulo: 'Criar grupo',
                              aoTocar: _novoGrupo,
                            )
                          : RefreshIndicator(
                              onRefresh: () => prov.carregar(),
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                                children: [
                                  if (prov.erro != null) BannerConexao(aoTentar: () => prov.carregar()),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                                    child: Text('Seus grupos',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  ),
                                  ...prov.grupos.map((g) => _cardGrupo(context, g)),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context, String nome, int total) {
    final cor = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D6B), Color(0xFF49B194)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism, color: Colors.white),
              const SizedBox(width: 8),
              const Text('CuidaBem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                onPressed: _entrarConvite,
                icon: const Icon(Icons.vpn_key, color: Colors.white),
                tooltip: 'Entrar com convite',
              ),
              IconButton(
                onPressed: _sair,
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sair',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Ola, $nome!', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            total == 0 ? 'Vamos comecar criando um grupo de cuidado' : 'Voce acompanha $total grupo(s) de cuidado',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _cardGrupo(BuildContext context, dynamic g) {
    final cor = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          context.read<GrupoProvider>().selecionar(g);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => GrupoHomeScreen(grupo: g)));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cor.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.elderly, color: cor.onPrimaryContainer, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.nome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Idoso: ${g.nomeIdoso}', style: TextStyle(color: cor.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.groups, size: 16, color: cor.outline),
                      const SizedBox(width: 4),
                      Text('${g.membros.length} membro(s)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor.outline)),
                    ]),
                  ],
                ),
         