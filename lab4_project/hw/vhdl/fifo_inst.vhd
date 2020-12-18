fifo_inst : fifo PORT MAP (
		clock	 => clock_sig,
		data	 => data_sig,
		rdreq	 => rdreq_sig,
		wrreq	 => wrreq_sig,
		almost_empty	 => almost_empty_sig,
		empty	 => empty_sig,
		q	 => q_sig
	);
