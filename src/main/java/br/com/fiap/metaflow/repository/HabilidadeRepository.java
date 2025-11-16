package br.com.fiap.metaflow.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.fiap.metaflow.model.Habilidade;

@Repository
public interface HabilidadeRepository extends JpaRepository<Habilidade, Long> {
}