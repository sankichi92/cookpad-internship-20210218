let global_count = 0;

const add_button = document.getElementById("add-cand");
add_button.addEventListener("click", () => {
	const parent = add_button.parentElement.parentElement;
	const cand_elem = document.createElement("li");
	const input = document.createElement("input");
	const rm_button = document.createElement("button");
	rm_button.innerText = "削除";
	rm_button.setAttribute("type", "button");
	rm_button.setAttribute("class", "cand-remove");
	rm_button.addEventListener("click", function () {
		parent.removeChild(cand_elem);
	});
	input.setAttribute("type", "text");
	input.setAttribute("name", "cand" + (++global_count).toString());
	input.setAttribute("value", "候補" + global_count.toString());
	cand_elem.appendChild(input);
	cand_elem.appendChild(rm_button);
	parent.insertBefore(cand_elem, add_button.parentElement);
})
