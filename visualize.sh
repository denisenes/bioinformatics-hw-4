make READS="SRR12717711" -p | python3 make_p_to_json.py | python3 json_to_dot.py | dot -Tpdf >| workflow.pdf
