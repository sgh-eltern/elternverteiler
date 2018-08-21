Sequel.migration do
  up do
    self.run <<~EOS
      ALTER TABLE ONLY public."schüler" DROP CONSTRAINT "schüler_klasse_id_fkey";
      ALTER TABLE ONLY public."schüler" ADD CONSTRAINT "schüler_klasse_id_fkey" FOREIGN KEY (klasse_id) REFERENCES public.klasse(id) ON DELETE CASCADE;
    EOS
  end

  down do
    self.run <<~EOS
      ALTER TABLE ONLY public."schüler" DROP CONSTRAINT "schüler_klasse_id_fkey";
      ALTER TABLE ONLY public."schüler" ADD CONSTRAINT "schüler_klasse_id_fkey" FOREIGN KEY (klasse_id) REFERENCES public.klasse(id) ON DELETE CASCADE;
    EOS
  end
end
