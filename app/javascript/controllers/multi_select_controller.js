import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

const REGEX_EMAIL = '([a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@' +
                    '(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)';

const formatName = function(item) {
    return ((item.name || '')).trim();
};

export default class extends Controller {
    static targets = ["select"];

    connect() {
        this.selectTargets.forEach((element) => {
            const select = new TomSelect(element, {
                persist: false,
                create: true,
                maxItems: null,
                maxOptions: 10,
                valueField: 'id',
                labelField: 'name',
                searchField: ['name', 'email'],
                placeholder: "Select members",
                sortField: [
                    { field: 'name', direction: 'asc' },
                    { field: 'email', direction: 'asc' }
                ],
                render: {
                    item: function(item, escape) {
                        var name = formatName(item);
                        return '<div>' +
                            (name ? '<span class="name">' + escape(name) + '</span>' : '') +
                            (item.email ? '<span class="email">' + escape(item.email) + '</span>' : '') +
                        '</div>';
                    },
                    option: function(item, escape) {
                        var name = formatName(item);
                        var label = name || item.email; 
                        var caption = name != '' ? item.email : null;
                        return '<div>' +
                            '<span class="label">' + escape(label) + '</span>' +
                            (caption ? '<span class="captio">' + escape(caption) + '</span>' : '') +
                        '</div>';
                    }
                },
                createFilter: function(input) {
                    const regexpA = new RegExp('^' + REGEX_EMAIL + '$', 'i');
                    const regexpB = new RegExp('^([^<]*)\<' + REGEX_EMAIL + '\>$', 'i');
                    return regexpA.test(input) || regexpB.test(input);
                },
                onInitialize() {
                    const input = this.control_input;
                    if (input) {
                        input.classList.add("form-control");
                    }
                },
                create: function(input) {
                    if ((new RegExp('^' + REGEX_EMAIL + '$', 'i')).test(input)) {
                        return {email: input};
                    }
                    var match = input.match(new RegExp('^([^<]*)\<' + REGEX_EMAIL + '\>$', 'i'));
                    if (match) {
                        var name = match[1].trim();

                        return {
                            email: match[2],
                            name: name
                        };
                    }
                    alert("Invalid email address.");
                    return false;
                },
                plugins: ['dropdown_input', 'clear_button', 'remove_button'],
            });
            select.on("change", () => {
                const selectedValues = select.getValue();
                const now = new Date().getTime();
                const expiresIn30Min = now + 30 * 60 * 1000;
            
                const data = {
                value: selectedValues,
                expiresAt: expiresIn30Min
                };
            
                localStorage.setItem("selectedMembers", JSON.stringify(data));
            });
            
    
            const savedMembers = JSON.parse(localStorage.getItem("selectedMembers"));
            if (savedMembers) {
                select.setValue(savedMembers);
            }
    });
    }
}
