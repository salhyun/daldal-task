(function($) {
    jQuery.fn.timepicker = function() {

        var button = $(this).children('button');
        var menu = $(this).children('.dropdown-menu');
        if(menu.length == 1) {

            $(menu).css('height', 'auto');
            $(menu).css('max-height', '200px');
            $(menu).css('overflow-x', 'hidden');

            var timelist = ['12:00', '12:30', '1:00', '1:30', '2:00', '2:30', '3:00', '3:30', '4:00', '4:30', '5:00', '5:30', '6:00', '6:30', '7:00', '7:30', '8:00', '8:30', '9:00', '9:30', '10:00', '10:30', '11:00', '11:30'];

            for(var t of timelist) {
                var item = $("<a class=\"dropdown-item\" href=\"javascript:void(0)\">" + t + " AM</a>");
                menu.append(item);
                item.click(function() {
                    console.log('click dropdown-item' + $(this).text());
                    button.text($(this).text());
                });
            }
            for(var t of timelist) {
                var item = $("<a class=\"dropdown-item\" href=\"javascript:void(0)\">" + t + " PM</a>");
                menu.append(item);
                item.click(function() {
                    console.log('click dropdown-item' + $(this).text());
                    button.text($(this).text());
                });
            }
        }
    };
})(jQuery);

