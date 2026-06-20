'use strict';

// Interface de persistencia de Grupos (UC002). Implementada por memoria e Firestore.
// Favorece manutenibilidade e SOLID (RNF008): a infraestrutura pode ser trocada
// sem impacto nos controllers/servicos.
class IGrupoRepository {
  async criar(grupo) { throw new Error('nao implementado'); }
  async buscarPorId(id) { throw new Error('nao implementado'); }
  async buscarPorMembro(usuarioId) { throw new Error('nao implementado'); }
  async buscarPorTokenConvite(token) { throw new Error('nao implementado'); }
  async salvar(grupo) { throw new Error('nao implementado'); }
}

module.exports = IGrupoRepository;
