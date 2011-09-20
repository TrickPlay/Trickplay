
window.addEventListener("load",function() {
    var labels = document.getElementsByTagName("a");

    var i;
    for (i=0; i < labels.length; i++)
    {
        var label = labels.item(i);

        if (
                label.innerHTML == "Classes" ||
                label.innerHTML == "Globals" ||
                label.innerHTML == "Interfaces"
            )
        {
                label.nextSibling.style.display = "block";
        }
    }

}, false);
