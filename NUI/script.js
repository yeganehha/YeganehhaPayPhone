var isFirstButtonPress = true;
var isDialing = false;
var lcdDisplay = document.getElementById("lcd-display");
var lcdText = document.getElementById("lcd-text");
var number = "";
var openPhoneNumber = "";
var outOfOrder = false;

var audioContextClass =
  window.AudioContext ||
  window.webkitAudioContext ||
  window.mozAudioContext ||
  window.oAudioContext ||
  window.msAudioContext;

function resetDisplay() {
  lcdText.classList.remove("blink");
  lcdText.textContent = "";
}

function hangUp() {
  // Reset the blink class after the animation ends
  lcdText.classList.remove("blink");
  lcdText.textContent = "";
  isDialing = false;
  $.post(
    "https://YeganehhaPayPhone/exit",
    JSON.stringify({
      number: lcdText.textContent,
    })
  );
}

function dial() {
  isDialing = true;
  lcdText.classList.add("blink");
  $.post(
    "https://YeganehhaPayPhone/dial",
    JSON.stringify({
      number: lcdText.textContent,
      myNumber: openPhoneNumber
    })
  );
}

function updateDisplay(value) {
  if (isFirstButtonPress) {
    lcdText.textContent = "";
    isFirstButtonPress = false;
  }

  if (lcdText.textContent.length === 3 || lcdText.textContent.length === 7) {
    lcdText.textContent += "-";
  }
  if (lcdText.textContent.length === 12) {
    return;
  }

  lcdText.textContent += value;
}

$(function () {
  $("#payphone").hide();

  window.addEventListener("message", function (event) {
    var eventData = event.data;

    if (eventData.action == "ui") {
      if (eventData.toggle) {
        $("#branding").text(eventData.brand + " Telephony");
        var phoneNumber = eventData.phoneNumber;
        myNumber = phoneNumber;
        $("#this-phone-number").text(
          "# " +
            [
              phoneNumber.slice(0, 3),
              "-",
              phoneNumber.slice(3, 6),
              "-",
              phoneNumber.slice(6),
            ].join("")
        );
        $("#payphone").fadeIn(250);
      } else {
        $("#payphone").fadeOut(50);
        $("#this-phone-number").text("");
        lcdText.textContent = "";
        lcdText.classList.remove("blink");
        outOfOrder = false;
      }
    }
  });
});
