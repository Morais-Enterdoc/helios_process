# Sistema de Consultoria / Helios Process

Projeto Flutter voltado para gestão de consultoria, processos, chamados, tarefas, agenda, cronograma, clientes e análises estruturadas de fluxos de trabalho.

## Visão geral

O Sistema de Consultoria / Helios Process é uma aplicação desenvolvida em Flutter para apoiar rotinas operacionais e gerenciais relacionadas a consultoria, acompanhamento de demandas, cronogramas, tarefas, agendas, clientes e estruturação de processos.

A aplicação utiliza uma arquitetura organizada por features, com separação entre camadas de dados, domínio e apresentação, facilitando manutenção, evolução e reaproveitamento de código.

## Tecnologias principais

- Flutter
- Dart
- Estrutura modular por feature
- Organização em camadas
- Banco de dados local definido em `core/database/app_database.dart`

## Estrutura principal

A organização principal do projeto está na pasta `lib/`.

```text
lib/
  app.dart
  main.dart
  core/
  features/
  shared/
```

## Organização arquitetural

### app.dart
Arquivo principal de composição da aplicação.

### main.dart
Ponto de entrada da aplicação.

### core
Contém elementos centrais e reutilizáveis de infraestrutura, incluindo banco de dados.

### shared
Contém elementos compartilhados entre múltiplas features, como widgets globais.

### features
Contém os módulos do sistema, organizados por responsabilidade funcional.

Cada feature segue, quando aplicável, a divisão:

- `data`: acesso e persistência de dados
- `domain`: entidades e modelos de negócio
- `presentation`: telas, páginas, widgets e elementos visuais

## Features identificadas

### Home
- `features/home/presentation/home_page.dart`

### Agenda
- `agenda_manual_repository.dart`
- `agenda_manual.dart`
- `agenda_page.dart`

### Chamados
- `chamado_repository.dart`
- `chamado.dart`
- `chamado_import_service.dart`
- `chamados_page.dart`

### Clientes
- `cliente_repository.dart`
- `cliente.dart`
- `cliente_com_setores.dart`
- `setor.dart`
- `clientes_page.dart`

### Cronograma
- `cronograma_repository.dart`
- `cronograma_item.dart`
- `cronograma_models.dart`
- `cronograma_projeto.dart`
- `cronograma_projeto_page.dart`
- widgets:
    - `cronograma_gantt.dart`
    - `cronograma_grid.dart`
    - `cronograma_header_card.dart`
    - `cronograma_resumo_card.dart`

### SIPOC
Possui uma estrutura mais completa, com repositórios, entidades, páginas, abas e widgets para análise e modelagem de processos.

Inclui itens como:
- `sipoc_repository.dart`
- `as_is_repository.dart`
- `to_be_repository.dart`
- `gargalo_repository.dart`
- `evidencia_repository.dart`
- `plano_acao_repository.dart`
- `timeline_repository.dart`

Entidades e modelos:
- `sipoc.dart`
- `sipoc_detalhe.dart`
- `as_is.dart`
- `to_be.dart`
- `gargalo.dart`
- `evidencia.dart`
- `plano_acao_item.dart`
- `timeline_evento.dart`

Camada de apresentação:
- `sipoc_page.dart`
- `sipoc_workspace_page.dart`

Abas:
- `sipoc_tab.dart`
- `timeline_tab.dart`
- `gargalos_tab.dart`
- `evidencias_tab.dart`
- `plano_acao_tab.dart`
- `to_be_tab.dart`

Widgets:
- `sipoc_card.dart`
- `sipoc_details_tab.dart`
- `sipoc_form_content.dart`
- `sipoc_form_dialog.dart`
- `sipoc_preview_widget.dart`
- `sipoc_tabs.dart`
- `sipoc_workspace_header.dart`
- `as_is_tab.dart`
- `as_is_form_dialog.dart`

### Tarefas
- `tarefa_repository.dart`
- `tarefa.dart`
- `tarefa_detalhe.dart`
- `tarefas_page.dart`

### Timeline
- `timeline_repository.dart`
- `timeline_item.dart`
- `timeline_page.dart`

## Banco de dados

A estrutura atual indica uso de banco de dados local através de:

- `core/database/app_database.dart`

## Componentes compartilhados

Atualmente existe pelo menos um widget compartilhado identificado:

- `shared/widgets/app_menu.dart`

## Diretrizes de desenvolvimento

- Sempre analisar primeiro a feature correta antes de criar novos arquivos.
- Respeitar a separação entre `data`, `domain` e `presentation`.
- Evitar duplicação de responsabilidade entre features.
- Priorizar reaproveitamento de widgets, repositories e modelos já existentes.
- Ao implementar alterações:
    - dados e persistência: analisar `data`
    - regras e entidades: analisar `domain`
    - telas e interface: analisar `presentation`
- Alterações globais devem ser avaliadas em `core` ou `shared`, quando fizer sentido.

## Apoio com IA

Este projeto utiliza o Perplexity como copiloto técnico de desenvolvimento.

Regras desejadas de apoio:
- respostas em português
- explicações passo a passo
- uma tarefa por vez
- indicação exata de arquivo, classe e bloco
- código completo e pronto para colar
- pausa para teste antes de seguir ao próximo passo

## Arquivos de referência recomendados

Além deste README, é recomendado manter no Space:
- estrutura da pasta `lib`
- notas sobre arquitetura
- convenções de desenvolvimento
- decisões importantes por feature

## Observação

A estrutura do projeto pode evoluir com o tempo. Este README deve ser atualizado sempre que houver mudanças relevantes na arquitetura, nas features ou na organização das camadas.