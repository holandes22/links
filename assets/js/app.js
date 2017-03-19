import "phoenix_html";
import $ from "jquery";

$(".message .close")
  .on("click", function() {
    $(this).parent(".message").fadeOut();
  });


$(".filters.button").popup({ popup: ".filters.popup", on: "click" });

let openModal = function(id) {
  let selector = `#delete_link_modal_${id}`;

  $(selector).modal({
    onDeny: () => {
      $(selector).modal("hide");
      return false;
    }
  })
  .modal("show");
};

window.Links = { openModal };
