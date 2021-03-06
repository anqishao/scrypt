#!/bin/sh

### Constants
c_valgrind_min=1
non_encoded_file="${scriptdir}/06-decrypt-fail.sh"
non_encoded_file_stderr="${s_basename}-stderr.txt"
non_encoded_file_output="${out}/nonfile.txt"

scenario_cmd() {
	# Attempt to decrypt a non-scrypt-encoded file.
	# We want this command to fail with 1.
	setup_check_variables
	(
		echo "" | ${c_valgrind_cmd} ${bindir}/scrypt		\
		    dec -P ${non_encoded_file}				\
		    ${non_encoded_file_output}				\
			2>> ${non_encoded_file_stderr}
		cmd_exitcode=$?

		if [ ${cmd_exitcode} -eq "1" ]; then
			echo "0"
		elif [ ${cmd_exitcode} -eq "${valgrind_exit_code}" ]; then
			echo ${valgrind_exit_code}
		else
			echo "1"
		fi > ${c_exitfile}
	)

	# We should have received an error mssage.
	setup_check_variables
	if grep -q "scrypt: Input is not valid scrypt-encrypted block" \
	    ${non_encoded_file_stderr}; then
		echo "0"
	else
		echo "1"
	fi > ${c_exitfile}

	# We should not have created a file.
	setup_check_variables
	if [ -e ${non_encoded_file_output}} ]; then
		echo "1"
	else
		echo "0"
	fi > ${c_exitfile}
}
