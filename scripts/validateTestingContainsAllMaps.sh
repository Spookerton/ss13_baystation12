#! /bin/bash 

cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../

fail=0

for k in src/maps/*; do
	map=${k#src/maps/}
	if [[ -e src/maps/$map/$map.dm ]] && ! grep -P "map_path: \[.*(?<=\[|,)\s*$map\s*(?=\]|,).*\]" .github/workflows/test.yml > /dev/null; then
		# $map is a valid map key, but the tests aren't checking it!
		fail=$((fail + 1))
		echo "Map key '$map' is present in the repository, but is not listed in .github/workflows/test.yml!"
	fi
done

exit $fail
