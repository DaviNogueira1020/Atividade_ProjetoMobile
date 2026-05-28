# Banco de Dados (SQLite) — SOS Cidade

Este documento descreve como ficará o **banco de dados local (SQLite)** do aplicativo **SOS Cidade** e como ele sustenta o “backend” dentro do Flutter (persistência + consultas + regras básicas).

A proposta é simples, rápida de implementar e suficiente para um protótipo funcional: uma tabela principal de **chamados** (tickets) com índices para deixar o **Dashboard** rápido e regras de integridade para não quebrar requisitos (ex.: **título único**).

---

## 1) Objetivo do banco

Guardar os chamados de forma **persistente** (os dados **não somem ao fechar o app**) e permitir:
- listagem ordenada por **prioridade** (alta/crítica no topo);
- contagens para os cards do Dashboard (abertos / em andamento / concluídos / críticos);
- filtros (bairro) e busca (título/descrição);
- bloqueios de regra (ex.: impedir título repetido via `UNIQUE`).

---

## 2) Entidade principal: Chamado

Um **Chamado** representa um problema urbano reportado por um cidadão.

Campos obrigatórios do enunciado:
- título
- descrição
- categoria
- prioridade
- bairro
- responsável
- data
- status

Campos técnicos adicionais (boas práticas):
- createdAt / updatedAt (para auditoria e ordenações)

> Importante: o **tempo desde a abertura** será **calculado**, não armazenado.
> Assim evitamos inconsistências e o tempo sempre aparece correto no app.

---

## 3) Enums e como serão persistidos

### Categorias (TEXT)
Para facilitar legibilidade e debug do banco, `categoria` será armazenada como **TEXT** (ex.: `"transito"`, `"iluminacao"`).

Valores aceitos:
- `transito`
- `iluminacao`
- `saneamento`
- `seguranca`
- `limpeza_urbana`
- `desastre_natural`

### Prioridade (INTEGER)
A prioridade será armazenada como **INTEGER**, pois isso facilita ordenação:
- 0 = baixa
- 1 = média
- 2 = alta
- 3 = crítica

### Status (INTEGER)
Status como **INTEGER** também facilita contagens e filtros:
- 0 = aberto
- 1 = em andamento
- 2 = concluído

---

## 4) Schema (DDL)

### Tabela `chamados`

**Observação:** datas serão guardadas como **epoch millis** (INTEGER), que é o mais prático no Flutter (`DateTime.millisecondsSinceEpoch`).

```sql
CREATE TABLE IF NOT EXISTS chamados (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo        TEXT    NOT NULL,
  descricao     TEXT    NOT NULL,
  categoria     TEXT    NOT NULL,
  prioridade    INTEGER NOT NULL,
  status        INTEGER NOT NULL,
  bairro        TEXT    NOT NULL,
  responsavel   TEXT    NOT NULL,
  data_abertura INTEGER NOT NULL,
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL,

  -- Regra de negócio: não permitir título repetido.
  CONSTRAINT uq_chamados_titulo UNIQUE (titulo)
);
```

> Nota: a validação de “descrição vazia” e “bairro vazio” também será feita no Service,
> mas o `NOT NULL` já impede valores nulos.

---

## 5) Índices (performance)

Índices ajudam o Dashboard e as buscas a ficarem rápidas mesmo com muitos registros.

```sql
CREATE INDEX IF NOT EXISTS idx_chamados_status
  ON chamados(status);

CREATE INDEX IF NOT EXISTS idx_chamados_prioridade
  ON chamados(prioridade);

CREATE INDEX IF NOT EXISTS idx_chamados_bairro
  ON chamados(bairro);

CREATE INDEX IF NOT EXISTS idx_chamados_data_abertura
  ON chamados(data_abertura);
```

---

## 6) Consultas que o app precisa (queries)

### 6.1) Lista principal do Dashboard (ordenada)
Prioridade **alta/crítica** no topo, e dentro da mesma prioridade os mais recentes primeiro:

```sql
SELECT *
FROM chamados
ORDER BY prioridade DESC, data_abertura DESC;
```

### 6.2) Contagem total

```sql
SELECT COUNT(*) AS total
FROM chamados;
```

### 6.3) Contagem por status (cards)

```sql
SELECT status, COUNT(*) AS qtd
FROM chamados
GROUP BY status;
```

### 6.4) Contagem de críticos (alerta visual)

```sql
SELECT COUNT(*) AS criticos
FROM chamados
WHERE prioridade = 3;
```

Regra de UI:
- se `criticos > 5`, mostrar alerta visual no Dashboard.

### 6.5) Filtro por bairro

```sql
SELECT *
FROM chamados
WHERE bairro = ?
ORDER BY prioridade DESC, data_abertura DESC;
```

### 6.6) Busca (título e descrição)

```sql
SELECT *
FROM chamados
WHERE titulo LIKE ? OR descricao LIKE ?
ORDER BY prioridade DESC, data_abertura DESC;
```

Parâmetros típicos no app:
- `query = "%texto%"`

---

## 7) Regras de negócio relacionadas ao banco

Estas regras serão implementadas principalmente na camada de **Service**, mas o banco ajuda a garantir integridade:

1) **Título único**
- Garantido por `UNIQUE(titulo)`.
- O Service também valida antes de inserir para retornar uma mensagem amigável.

2) **Descrição não pode ser vazia**
- Service valida `descricao.trim().isNotEmpty`.

3) **Bairro não pode ser vazio**
- Service valida `bairro.trim().isNotEmpty`.

4) **Chamado concluído não pode ser editado**
- Service bloqueia `UPDATE` quando `status == concluido (2)`.

5) **Alta/crítica no topo**
- Garantido pela ordenação `ORDER BY prioridade DESC`.

6) **Tempo desde a abertura**
- Calculado em runtime:
  - `tempo = DateTime.now().difference(dataAbertura)`

---

## 8) Migrações (versionamento)

Para protótipo, uma versão inicial já resolve:
- `version = 1`: cria tabela + índices.

Se depois vocês quiserem extras (ex.: foto, favoritos, geo/localização), é só:
- subir a versão do banco;
- executar `ALTER TABLE`/novas tabelas em `onUpgrade`.

---

## 9) Backend local (Flutter): como isso se encaixa no app

Mesmo sendo Flutter, dá para tratar como um “backend” local bem organizado:

- **DAO (data access)**: executa SQL e converte Map ⇄ Model.
- **Repository**: API de dados usada pelo resto do app.
- **Service**: regras de negócio (validações, bloqueios, mensagens).
- **State (Provider/Riverpod/Bloc)**: mantém estado do Dashboard/Form e re-carrega dados quando necessário.

Com isso, a UI fica limpa: ela só chama ações tipo `criarChamado`, `editarChamado`, `carregarDashboard`.

---

## 10) Checklist rápido (para garantir os requisitos)

- [x] Persistência SQLite (dados não somem)
- [x] Título único (`UNIQUE`)
- [x] Ordenação por prioridade (alta/crítica no topo)
- [x] Contagens por status + críticos
- [x] Regra de alerta visual (`criticos > 5`)
- [x] Bloqueio de edição quando concluído
- [x] Tempo desde a abertura calculado automaticamente

