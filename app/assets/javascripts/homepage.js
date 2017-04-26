var revapi26;
$(document).ready(function() {
    //setTimeout(setHeightOfAdvertisements(),300);    
    if($("#rev_slider1").revolution == undefined){
        revslider_showDoubleJqueryError("#rev_slider1");
    }else{
        revapi26 = $("#rev_slider1").show().revolution({
                sliderType:"standard",
                jsFileLocation:"vendor/revolution/js/",
                sliderLayout:"auto",
                dottedOverlay:"none",
                delay:9000,
                navigation: {
                    keyboardNavigation:"off",
                    keyboard_direction: "horizontal",
                    mouseScrollNavigation:"off",
                    onHoverStop:"on",
                    touch:{
                        touchenabled:"on",
                        swipe_threshold: 75,
                        swipe_min_touches: 1,
                        swipe_direction: "horizontal",
                        drag_block_vertical: false
                    }
                    ,
                    arrows: {
                        style: "rev_pesto",
                        enable: true,
                        hide_onmobile: true,
                        hide_under: 600,
                        hide_onleave: true,
                        hide_delay: 200,
                        hide_delay_mobile: 1200,
                        left:{
                            h_align:"left",
                            v_align:"center",
                            h_offset:30,
                            v_offset:0
                        },
                        right:{
                            h_align:"right",
                            v_align:"center",
                            h_offset:30,
                            v_offset:0
                        }
                    }
                    ,
                    thumbnails: {
                        style: 'rev_pesto',
                        enable: true,
                        width: 20,
                        height: 20,
                        min_width: 14,
                        wrapper_padding: 0,
                        wrapper_color: 'transparent',
                        wrapper_opacity: '1',
                        tmp: '<span class="tp-thumb-icon-circle"><i class="theme-icon pesto-icon-circle"></i></span>',
                        visibleAmount: 5,
                        hide_onmobile: true,
                        hide_under: 800,
                        hide_onleave: true,
                        direction: 'horizontal',
                        span: false,
                        position: 'inner',
                        space: 5,
                        h_align: 'center',
                        v_align: 'bottom',
                        h_offset: 0,
                        v_offset: 20
                    }
                },
                responsiveLevels:[1920,992,768],
                gridwidth: [1600,992,768],
                gridheight: [587,348,280],
                parallax: {
                    type:"mouse+scroll",
                    origo:"slidercenter",
                    speed:20000,
                    levels:[1,2,3,20,25,30,35,40,45,50],
                    disable_onmobile:"on"
                },
                spinner:"spinner3",
                stopLoop:"on",
                stopAfterLoops:0,
                stopAtSlide:1,
                shuffle:"off",
                autoHeight:"on",
                minHeight:"10",
                disableProgressBar:"on",
                hideThumbsOnMobile:"on",
                hideSliderAtLimit:0,
                hideCaptionAtLimit:0,
                hideAllCaptionAtLilmit:0,
                debugMode:false,
                fallbacks: {
                    simplifyAll:"off",
                    nextSlideOnWindowFocus:"off",
                    disableFocusListener:false,
                }
        });
    }
}); /*ready*/