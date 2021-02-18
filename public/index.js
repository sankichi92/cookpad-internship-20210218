const add_button = document.getElementById("add-cand");
add_button.addEventListener("click", () => {
	const parent = add_button.parentElement.parentElement;
	const new_id = parent.children.length;
	const cand_elem = document.createElement("li");
	const input = document.createElement("input");
	input.setAttribute("type", "text");
	input.setAttribute("name", "cand" + (new_id - 1).toString());
	input.setAttribute("value", "候補" + new_id.toString());
	cand_elem.appendChild(input);
	parent.insertBefore(cand_elem, add_button.parentElement);
})
