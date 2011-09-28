package com.trickplay.gameservice.controllers;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.validation.ConstraintViolation;
import javax.validation.Valid;
import javax.validation.Validator;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.Assert;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.trickplay.gameservice.domain.Game;
import com.trickplay.gameservice.domain.Vendor;
import com.trickplay.gameservice.service.UserService;
import com.trickplay.gameservice.service.VendorService;
import com.trickplay.gameservice.transferObj.BooleanResponse;
import com.trickplay.gameservice.transferObj.VendorRequestTO;
import com.trickplay.gameservice.transferObj.VendorTO;

@Controller
public class VendorController extends BaseController {
	private static final Logger logger = LoggerFactory.getLogger(VendorController.class);
	@Autowired
	private VendorService vendorService;
	@Autowired
	private UserService userService;
	
	@Autowired 
	Validator validator;
	

    @RequestMapping(value = {"/vendor", "/rest/vendor"}, method = RequestMethod.GET)
    public String getAllVendors(Model model) {
        List<Vendor> allVendors = vendorService.findAll();
        model.addAttribute("vendors", allVendors);
        model.addAttribute("numberOfVendors", allVendors.size());
        return "vendor/list";
    }

    @RequestMapping(value = {"/rest/vendor/exists"}, method = RequestMethod.GET)
    public @ResponseBody BooleanResponse checkVendorExists(@RequestParam(value="name", required=true) String name) {
        if (null != vendorService.findByName(name))
            return BooleanResponse.TRUE;
        else
            return BooleanResponse.FALSE;
    }
    
    @RequestMapping(value = {"/vendor/{id}", "/rest/vendor/{id}"}, method = RequestMethod.GET)
    public String getVendor(@PathVariable("id") Long vendorId, Model model) {
    	Assert.notNull(vendorId, "Identifier must be provided.");
		model.addAttribute("vendor", vendorService.find(vendorId));
		model.addAttribute("game", new Game());
		return "vendor/show";
    }
    
	@RequestMapping(value = "/vendor/form", method = RequestMethod.GET)
    public String newVendor(Model model) {
		VendorTO v = new VendorTO();
        model.addAttribute("vendor", v);
        return "vendor/create";
    }

	@RequestMapping(value = "/rest/vendor", method = RequestMethod.POST)
    public @ResponseBody VendorTO saveVendorGeneric(@RequestBody VendorRequestTO vendor) {
    	StringBuilder err = new StringBuilder();
    	boolean hasErrors = false;
    	for (ConstraintViolation<VendorRequestTO> constraint : validator.validate(vendor)) {
    		if (hasErrors)
                err.append(",");
            err.append("[").append(constraint.getMessage()).append("]");
            hasErrors = true;
		}

    	if (hasErrors) {
    		throw new BaseControllerException(400, null, "Invalid parameters. "
					+ err.toString());
        }
        
    	try {
    		return new VendorTO(userService.createVendor(vendor.getName()));
    	} catch(Exception e) {
    		throw new BaseControllerException(e);
    	}
    }

	@RequestMapping(value = "/vendor", method = RequestMethod.POST)
	public String saveVendor(@ModelAttribute("vendor") @Valid VendorTO vendor,
			BindingResult result, Model model, HttpServletRequest request) {
		

		if (result.hasErrors()) {
			model.addAttribute("vendor", vendor);
			return "vendor/create";
		}
		// create the vendor first
		Vendor newv = userService.createVendor(vendor.getName());

		return "redirect:/vendor/" + newv.getId();
	}
    


 }
