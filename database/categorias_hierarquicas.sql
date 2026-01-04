-- =====================================================
-- Atualização da tabela de categorias para hierarquia
-- Execute este script no MySQL para adicionar suporte
-- a categorias com subcategorias (parent_id) e ícones
-- =====================================================

-- Adicionar coluna de ícone (nome do ícone Lucide)
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS icone VARCHAR(50) DEFAULT NULL AFTER descricao;

-- Adicionar coluna parent_id para hierarquia
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS parent_id INT DEFAULT NULL AFTER icone;

-- Adicionar chave estrangeira para relacionamento hierárquico
ALTER TABLE categorias ADD CONSTRAINT fk_categoria_parent 
    FOREIGN KEY (parent_id) REFERENCES categorias(id) ON DELETE SET NULL;

-- Criar índice para melhorar performance de consultas hierárquicas
CREATE INDEX IF NOT EXISTS idx_categorias_parent ON categorias(parent_id);

-- =====================================================
-- Inserir categorias principais (baseadas nas imagens fornecidas)
-- =====================================================

-- Limpar categorias existentes (CUIDADO: apenas em ambiente de desenvolvimento)
-- DELETE FROM categorias;

-- Inserir categorias principais
INSERT INTO categorias (nome, slug, icone, ordem, parent_id, ativo) VALUES
('Autos e Peças', 'autos-pecas', 'car', 1, NULL, 1),
('Imóveis', 'imoveis', 'home', 2, NULL, 1),
('Casa, Decoração e Utensílios', 'casa-decoracao', 'lamp', 3, NULL, 1),
('Móveis', 'moveis', 'bed', 4, NULL, 1),
('Eletro', 'eletro', 'washing-machine', 5, NULL, 1),
('Materiais de Construção', 'materiais-construcao', 'hammer', 6, NULL, 1),
('Celulares e Telefonia', 'celulares-telefonia', 'smartphone', 7, NULL, 1),
('Informática', 'informatica', 'laptop', 8, NULL, 1),
('Games', 'games', 'gamepad-2', 9, NULL, 1),
('TVs e Vídeo', 'tvs-video', 'monitor', 10, NULL, 1),
('Áudio', 'audio', 'headphones', 11, NULL, 1),
('Câmeras e Drones', 'cameras-drones', 'camera', 12, NULL, 1),
('Moda e Beleza', 'moda-beleza', 'shirt', 13, NULL, 1),
('Comércio', 'comercio', 'store', 14, NULL, 1),
('Escritório e Home Office', 'escritorio-homeoffice', 'briefcase', 15, NULL, 1),
('Música e Hobbies', 'musica-hobbies', 'music', 16, NULL, 1),
('Esportes e Fitness', 'esportes-fitness', 'dumbbell', 17, NULL, 1),
('Artigos Infantis', 'artigos-infantis', 'baby', 18, NULL, 1),
('Animais de Estimação', 'animais-estimacao', 'paw-print', 19, NULL, 1),
('Agro e Indústria', 'agro-industria', 'tractor', 20, NULL, 1),
('Serviços', 'servicos', 'wrench', 21, NULL, 1),
('Vagas de Emprego', 'vagas-emprego', 'badge-check', 22, NULL, 1)
ON DUPLICATE KEY UPDATE icone = VALUES(icone), ordem = VALUES(ordem);

-- =====================================================
-- Exemplo de subcategorias para Celulares e Telefonia
-- =====================================================

-- Primeiro, obter o ID da categoria pai
SET @celulares_id = (SELECT id FROM categorias WHERE slug = 'celulares-telefonia' LIMIT 1);

-- Inserir subcategorias
INSERT INTO categorias (nome, slug, icone, ordem, parent_id, ativo) VALUES
('iPhone', 'iphone', 'smartphone', 1, @celulares_id, 1),
('Samsung', 'samsung', 'smartphone', 2, @celulares_id, 1),
('Xiaomi', 'xiaomi', 'smartphone', 3, @celulares_id, 1),
('Motorola', 'motorola', 'smartphone', 4, @celulares_id, 1),
('Acessórios', 'acessorios-celular', 'plug', 5, @celulares_id, 1)
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id);

-- =====================================================
-- Exemplo de subcategorias para Informática
-- =====================================================

SET @informatica_id = (SELECT id FROM categorias WHERE slug = 'informatica' LIMIT 1);

INSERT INTO categorias (nome, slug, icone, ordem, parent_id, ativo) VALUES
('MacBook', 'macbook', 'laptop', 1, @informatica_id, 1),
('Notebooks', 'notebooks', 'laptop', 2, @informatica_id, 1),
('Desktops', 'desktops', 'monitor', 3, @informatica_id, 1),
('Tablets', 'tablets', 'tablet', 4, @informatica_id, 1),
('iPad', 'ipad', 'tablet', 5, @informatica_id, 1),
('Periféricos', 'perifericos', 'keyboard', 6, @informatica_id, 1)
ON DUPLICATE KEY UPDATE parent_id = VALUES(parent_id);

-- =====================================================
-- Query para buscar categorias hierarquicamente
-- =====================================================

-- Exemplo: Buscar todas categorias principais (sem parent)
-- SELECT * FROM categorias WHERE parent_id IS NULL AND ativo = 1 ORDER BY ordem;

-- Exemplo: Buscar subcategorias de uma categoria
-- SELECT * FROM categorias WHERE parent_id = 7 AND ativo = 1 ORDER BY ordem;

-- =====================================================
-- View para facilitar consultas hierárquicas
-- =====================================================

CREATE OR REPLACE VIEW vw_categorias_hierarquia AS
SELECT 
    c.id,
    c.nome,
    c.slug,
    c.icone,
    c.parent_id,
    c.ordem,
    c.ativo,
    p.nome AS categoria_pai,
    p.slug AS slug_pai,
    CASE WHEN c.parent_id IS NULL THEN 0 ELSE 1 END AS nivel
FROM categorias c
LEFT JOIN categorias p ON c.parent_id = p.id
WHERE c.ativo = 1
ORDER BY COALESCE(c.parent_id, c.id), c.ordem;
